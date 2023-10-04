# typed: strict

module ResourceRegistry
  module Graphql
    class SchemaArgumentResolver
      extend T::Sig

      sig { params(resolved_types: T::Hash[String, T.untyped]).void }
      def initialize(resolved_types)
        @resolved_types = resolved_types
      end

      sig do
        params(
          property: SchemaRegistry::Property,
          prefix: T.nilable(String),
          verb: T.nilable(Symbol)
        ).returns(SchemaArgument)
      end
      def call(property, prefix = '', verb = nil)
        argument_type = resolve_argument_type(deep_resolve_property(property, prefix, verb))

        SchemaArgument.new(name: property.name, type: argument_type, required: required?(property))
      end

      private

      sig { params(property: SchemaRegistry::Property).returns(T::Boolean) }
      def required?(property)
        # This attempts to be very permissive with clients contacting the API, implementation will
        # do a best effort if a field is not sent to assume the correct value.
        property.required? && !property.nilable? && T.unsafe(property.default).blank?
      end

      sig do
        params(
          property: SchemaRegistry::Property,
          prefix: T.nilable(String),
          verb: T.nilable(Symbol)
        ).returns(T.untyped)
      end
      def deep_resolve_property(property, prefix, verb)
        if !property.items.empty?
          deep_resolve_array(property, prefix, verb)
        elsif !property.properties.empty?
          type_name = resolve_argument_name(property, prefix)
          if resolved_types.key?(type_name)
            resolved_types[type_name]
          else
            new_input = Class.new(::GraphQL::Schema::InputObject)
            unless property.name.blank?
              new_input.graphql_name(type_name)
              resolved_types[type_name] = new_input
            end

            fields = property.properties.map { |p| deep_resolve_property(p, prefix, verb) }
            resolve_fields(fields, property, new_input)

            new_input
          end
        else
          { parent: property, type: SchemaTypeToGraph.call(property, prefix, resolved_types) }
        end
      end

      sig do
        params(
          property: SchemaRegistry::Property,
          prefix: T.nilable(String),
          verb: T.nilable(Symbol)
        ).returns(T::Array[T.untyped])
      end
      def deep_resolve_array(property, prefix, verb)
        type_name = resolve_argument_name(property, prefix)

        return [resolved_types[type_name]] if resolved_types.key?(type_name)

        input = deep_resolve_property(T.must(property.items.first), prefix, verb)

        if input.respond_to?(:graphql_name) && !property.name.blank?
          input.graphql_name(type_name)
          resolved_types[type_name] = input
        end

        [input]
      end

      sig do
        params(
          fields: T::Array[Object],
          property: SchemaRegistry::Property,
          input: T.class_of(::GraphQL::Schema::InputObject)
        ).void
      end
      def resolve_fields(fields, property, input)
        fields.each_with_index do |field, i|
          property_i = T.must(property.properties[i])
          case field
          when Hash
            input.argument(field[:parent].name, field[:type], required: required?(field[:parent]))
          when Array
            if field.first.is_a?(Hash)
              input.argument(property_i.name, [field.first[:type]], required: required?(property_i))
            else
              input.argument(property_i.name, field, required: required?(property_i))
            end
          else
            input.argument(property_i.name, field, required: required?(property_i))
          end
        end
      end

      sig { params(argument_type: T.untyped).returns(T.any(T.untyped, T::Array[T.untyped])) }
      def resolve_argument_type(argument_type)
        return argument_type[:type] if argument_type.is_a?(Hash)
        return argument_type unless argument_type.is_a?(Array)

        return [argument_type.first[:type]] if argument_type.first.is_a?(Hash)
        [argument_type.first]
      end

      sig { params(property: SchemaRegistry::Property, prefix: T.nilable(String)).returns(String) }
      def resolve_argument_name(property, prefix)
        # if property is a value-object, we get the name from the type instead of from the property name to allow it to be reused
        name =
          if property.value_object?
            property.type_name.to_s.sub('ValueObjects::', '').gsub('::', '_').underscore
          else
            prefix.blank? ? property.name : "#{prefix}_#{property.name}"
          end.camelize

        "#{name}Input"
      end

      sig { returns(T::Hash[String, T.untyped]) }
      attr_accessor :resolved_types
    end
  end
end
