# typed: strict

require 'sorbet-coerce'

module ResourceRegistry
  # Constructs a resource struct (like Dtos and Entities) from a hash of arguments
  # It's different from the usual T::Struct::new in that it can handle
  # the particular cases of our resource objects, such as:
  # - nested Dtos
  # - arrays of Dtos
  # - `Maybe[T]` values
  class ResourceStructBuilder
    extend T::Sig

    class ParseInputError < StandardError
    end

    sig { params(resource_type: T.untyped).void }
    def initialize(resource_type)
      @resource_type = resource_type
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def build(value)
      return value if resource_type.nil?

      case true # rubocop:disable Lint/LiteralAsCondition
      when generic?
        build_generic(value)
      when array? # Primitives will return true here
        build_enumerable(value)
      when struct?
        # GraphQL will sometimes send its own classes into here. We need to convert them to hashes.
        build_struct(value.to_h)
      when set?
        build_enumerable(value).to_set
      else
        build_other(value)
      end
    rescue TypeError, ArgumentError, TypeCoerce::CoercionError => e
      raise ParseInputError, e.message
    end

    private

    sig { returns(T::Boolean) }
    def generic?
      resource_type.is_a?(RuntimeGeneric::TypedGeneric)
    end

    sig { returns(T::Boolean) }
    def struct?
      (type.is_a?(Class) && type.ancestors.include?(T::Struct)) ||
        (
          resource_type.is_a?(T::Types::Union) &&
            resource_type.types.any? { |t| t.raw_type.ancestors.include?(T::Struct) }
        )
    end

    sig { returns(T::Boolean) }
    def array?
      resource_type.is_a?(T::Types::TypedArray) ||
        (resource_type.is_a?(T::Types::Union) && resource_type.types.any?(T::Types::TypedArray))
    end

    sig { returns(T::Boolean) }
    def set?
      resource_type.is_a?(T::Types::TypedSet) ||
        (resource_type.is_a?(T::Types::Union) && resource_type.types.any?(T::Types::TypedSet))
    end

    sig { returns(T.untyped) }
    # The difference between `#resource_type` and this is that, for `Simple` types, this returns the
    # actual type. In any other case, it will be the same. Both are necessary because on complex
    # types we need the `resource_type` to do further instrospection and the type to build instances
    def type
      case resource_type
      when T::Types::Simple
        resource_type.raw_type
      else
        resource_type
      end
    end

    sig { params(outer_type: T.untyped).returns(T.untyped) }
    # Calculates the inner type of a complex type
    def inner_type(outer_type)
      case outer_type
      when RuntimeGeneric::TypedGeneric
        outer_type.inner_type
      when T::Types::Simple
        outer_type.raw_type
      when T::Types::TypedArray
        inner_type(outer_type.type)
      when T::Types::Union
        inner_type(
          resource_type.types.find { |t| !t.is_a?(T::Types::Simple) || t.raw_type != NilClass }
        )
      else
        outer_type
      end
    end

    sig { params(args: T::Hash[T.untyped, T.untyped]).returns(T::Struct) }
    def build_struct(args)
      inner_type(resource_type).new(
        args.symbolize_keys.filter_map { |key, value| build_struct_property(key, value) }.to_h
      )
    end

    sig { params(key: Symbol, value: T.untyped).returns(T.nilable([Symbol, T.untyped])) }
    def build_struct_property(key, value)
      prop = inner_type(resource_type).decorator&.props&.[](key)
      return if prop.nil? # filter out props that are not defined in the struct

      prop_type_object = prop&.[](:type_object)
      resolved = ResourceStructBuilder.new(prop_type_object).build(value)

      [key, resolved]
    end

    sig { params(args: T.nilable(T.all(Object, T::Enumerable[T.untyped]))).returns(T.untyped) }
    def build_enumerable(args)
      return args if args.nil?

      inner_builder = ResourceStructBuilder.new(inner_type(resource_type))
      args.map { |value| inner_builder.build(value) }
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def build_generic(value)
      inner_type = inner_type(resource_type)
      type.new(ResourceStructBuilder.new(inner_type).build(value))
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def build_other(value)
      return value if value.nil?

      TypeCoerce[resource_type].from(value)
    end

    sig { returns(T.untyped) }
    attr_reader :resource_type
  end
end
