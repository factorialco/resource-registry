# typed: strict

module SchemaRegistry
  class GenerateFromStruct
    extend T::Sig

    class SolvableNestedTypes < T::Enum
      enums do
        Dtos = new("Dtos")
        Entities = new("Entities")
        ValueObjects = new("ValueObjects")
      end
    end

    sig { params(struct_klass: T.class_of(T::Struct)).void }
    def initialize(struct_klass:)
      @struct_klass = struct_klass
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      struct_key = struct_klass.to_s.split("::").last

      schema = {}

      schema[struct_key] = { "type" => "object", "properties" => {} }

      schema[struct_key]["properties"] = deep_generate_properties(struct_klass)
      schema[struct_key]["required"] = calculate_required(struct_klass)

      schema
    end

    private

    sig { returns(T.class_of(T::Struct)) }
    attr_reader :struct_klass

    sig do
      params(klass: T.class_of(T::Struct)).returns(T::Hash[Symbol, T.untyped])
    end
    def deep_generate_properties(klass)
      props = klass.decorator.props

      props.each_with_object({}) do |prop, memo|
        name = prop[0]
        definition = prop[1]
        type_object = definition[:type_object]
        typedef = type_definition(definition, type_object)

        memo[name.to_s] = (
          if typedef.instance_of?(T::Types::TypedArray)
            deep_generate_array(typedef, prop)
          else
            type =
              sorbet_type_to_json(
                type: typedef,
                type_object: type_object,
                nilable: !required?(definition)
              )
            {
              "type" => type,
              "typedef" => typedef,
              "enum" => (typedef.values.map(&:serialize) if enum?(typedef)),
              "properties" =>
                (
                  if can_resolve_type?(typedef)
                    deep_generate_properties(typedef)
                  end
                ),
              "required" => calculate_required(typedef),
              "format" => sorbet_type_to_json_format(type: typedef),
              "default" => compute_default(definition)
            }.compact
          end
        )
      end
    end

    sig { params(klass: T.untyped).returns(T.nilable(T::Array[String])) }
    def calculate_required(klass)
      return unless klass.respond_to?(:decorator)
      klass.decorator.props.filter_map do |prop|
        prop[0].to_s if required?(prop[1])
      end
    end

    sig { params(definition: T.untyped).returns(T::Boolean) }
    def required?(definition)
      typedef = definition[:type]
      typedef != Maybe && !definition[:fully_optional]
    end

    sig do
      params(typedef: T.untyped, prop: T.untyped).returns(
        T::Hash[T.untyped, T.untyped]
      )
    end
    def deep_generate_array(typedef, prop)
      if typedef.type.respond_to?(:raw_type)
        array_type =
          sorbet_type_to_json(type: typedef.type.raw_type, nilable: false)
        {
          "type" =>
            sorbet_type_to_json(type: typedef, nilable: !required?(prop[1])),
          "typedef" => typedef.type.raw_type,
          "items" => deep_generate_items(array_type, typedef),
          "default" => compute_default(prop[1])
        }.compact
      else
        # Gate to algebraic data types in arrays
        { "type" => "string" }
      end
    end

    sig do
      params(
        array_type: T.any(T::Array[String], String),
        typedef: T.untyped
      ).returns(T::Hash[T.untyped, T.untyped])
    end
    def deep_generate_items(array_type, typedef)
      {
        "type" => array_type,
        "typedef" => typedef.type.raw_type,
        "enum" =>
          (
            if enum?(typedef.type.raw_type)
              typedef.type.raw_type.values.map(&:serialize)
            end
          ),
        "properties" =>
          (
            if can_resolve_type?(typedef.type.raw_type)
              deep_generate_properties(typedef.type.raw_type)
            end
          ),
        "format" => sorbet_type_to_json_format(type: typedef.type.raw_type),
        "required" => calculate_required(typedef.type.raw_type)
      }.compact
    end

    sig { params(typedef: T.untyped).returns(T::Boolean) }
    def can_resolve_type?(typedef)
      type = sorbet_type_to_json(type: typedef)
      type == "object" &&
        typedef
          .to_s
          .split("::")
          .any? { |t| SolvableNestedTypes.has_serialized?(t) }
    end

    sig { params(prop: T.untyped).returns(SchemaRegistry::Property::ValueType) }
    def compute_default(prop)
      return if prop[:default].nil?

      case prop[:default]
      when T::Enum
        prop[:default].serialize
      when Proc
        prop[:default].call
      else
        prop[:default]
      end
    end

    sig do
      params(
        type: T.any(Integer, T::Types::Union, T.untyped),
        type_object: T.untyped,
        nilable: T::Boolean
      ).returns(T.any(String, T::Array[String]))
    end
    #rubocop:disable Metrics/PerceivedComplexity
    def sorbet_type_to_json(type:, type_object: nil, nilable: false)
      if nilable
        return nilable_sorbet_type_to_json(type: type, type_object: type_object)
      end

      return "integer" if type == Integer
      return "number" if type == Float
      return "boolean" if type.is_a?(T::Types::Union) || type == T::Boolean
      return "string" if type == ActionDispatch::Http::UploadedFile
      return "array" if type.is_a?(T::Types::TypedArray)
      return "string" if represented_as_string?(type)

      "object"
    end
    #rubocop:enable Metrics/PerceivedComplexity

    sig do
      params(
        type: T.any(Integer, T::Types::Union, T.untyped),
        type_object: T.untyped
      ).returns(T::Array[String])
    end
    def nilable_sorbet_type_to_json(type:, type_object: nil)
      fixed_type = sorbet_type_to_json(type: type)

      (["null"] + [fixed_type]).flatten.uniq
    end

    sig { params(type: T.untyped).returns(T::Boolean) }
    def represented_as_string?(type)
      enum?(type) ||
        [String, DateTime, ActiveSupport::TimeWithZone, Date, Time].include?(
          type
        )
    end

    sig { params(type: T.untyped).returns(T::Boolean) }
    def enum?(type)
      return true if type.is_a?(Class) && type <= T::Enum
      false
    end

    sig { params(type: T.untyped).returns(T.nilable(String)) }
    def sorbet_type_to_json_format(type:)
      return "binary" if type == ActionDispatch::Http::UploadedFile
      return "date-time" if type == DateTime
      return "time" if [ActiveSupport::TimeWithZone, Time].include?(type)
      return "date" if type == Date

      nil
    end

    sig do
      params(definition: T.untyped, type_object: T.untyped).returns(T.untyped)
    end
    def type_definition(definition, type_object)
      typedef = definition[:type]
      typedef = typedef.returns if typedef.is_a?(T::Types::Proc)

      return typedef unless typedef == Maybe && type_object

      inner_type = type_object.inner_type

      return inner_type unless inner_type.is_a?(T::Types::Union)

      union_type_definition(inner_type)
    end

    sig { params(type: T.untyped).returns(T.untyped) }
    def union_type_definition(type)
      # For unions (T.nilable, T::Boolean...), we must first remove the nils.
      # Otherwise, it will be confused with a Boolean.
      non_nil_types =
        type.types.filter do |t|
          !t.is_a?(T::Types::Simple) || t.raw_type != NilClass
        end

      if non_nil_types.count > 1
        # T.nilable(T::Boolean) is an union with 3 types. We merge it again as one
        T::Types::Union.new(non_nil_types)
      elsif !non_nil_types.empty?
        # For simple nilables, we take the non-nil type
        non_nil_types[0].raw_type
      else
        # If there aren't non-nil types, we fallback to the original type
        type
      end
    end
  end
end
