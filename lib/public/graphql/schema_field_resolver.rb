# typed: strict

module ResourceRegistry
  module Graphql
    class SchemaFieldResolver
      extend T::Sig

      sig { params(resolved_types: T::Hash[String, T.untyped]).void }
      def initialize(resolved_types)
        @resolved_types = resolved_types
      end

      sig do
        params(property: SchemaRegistry::Property, prefix: T.nilable(String)).returns(SchemaField)
      end
      def call(property, prefix = '')
        field_type = resolve_field_type(deep_resolve_property(property, prefix))

        SchemaField.new(name: property.name, type: field_type)
      end

      private

      sig { params(property: SchemaRegistry::Property).returns(T::Boolean) }
      def required?(property)
        # This attempts to be very permissive with clients contacting the API, implementation will
        # do a best effort if a field is not sent to assume the correct value.
        property.required? && !property.nilable? && T.unsafe(property.default).blank?
      end

      sig do
        params(property: SchemaRegistry::Property, prefix: T.nilable(String)).returns(T.untyped)
      end
      def deep_resolve_property(property, prefix)
        if property.items.any?
          deep_resolve_array(property, prefix)
        elsif property.properties.any? && property.value_object?
          type_name = resolve_field_name(property, prefix)
          if resolved_types.key?(type_name)
            resolved_types[type_name]
          else
            new_field = Class.new(BaseObject)
            unless property.name.blank?
              new_field.graphql_name(type_name)
              resolved_types[type_name] = new_field
            end

            fields = property.properties.map { |p| deep_resolve_property(p, prefix) }
            resolve_fields(fields, property, new_field)

            new_field
          end
        else
          { parent: property, type: SchemaTypeToGraph.call(property, prefix, resolved_types) }
        end
      end

      sig do
        params(property: SchemaRegistry::Property, prefix: T.nilable(String)).returns(
          T::Array[T.untyped]
        )
      end
      def deep_resolve_array(property, prefix)
        type_name = resolve_field_name(property, prefix)

        input =
          if resolved_types.key?(type_name)
            resolved_types[type_name]
          else
            new_field = deep_resolve_property(T.must(property.items.first), prefix)
            if new_field.respond_to?(:graphql_name) && !property.name.blank?
              new_field.graphql_name(type_name)
              resolved_types[type_name] = new_field
            end
            new_field
          end
        [input]
      end

      sig do
        params(
          fields: T::Array[Object],
          property: SchemaRegistry::Property,
          input: T.class_of(BaseObject)
        ).void
      end
      def resolve_fields(fields, property, input)
        fields.each_with_index do |field, i|
          property_i = T.must(property.properties[i])
          case field
          when Hash
            input.field(field[:parent].name, field[:type], null: !required?(field[:parent]))
          when Array
            if field.first.is_a?(Hash)
              input.field(property_i.name, [field.first[:type]], null: !required?(property_i))
            else
              input.field(property_i.name, field, null: !required?(property_i))
            end
          else
            input.field(property_i.name, field, null: !required?(property_i))
          end
        end
      end

      sig { params(field_type: T.untyped).returns(T.any(T.untyped, T::Array[T.untyped])) }
      def resolve_field_type(field_type)
        return field_type[:type] if field_type.is_a?(Hash)
        return field_type unless field_type.is_a?(Array)

        return [field_type.first[:type]] if field_type.first.is_a?(Hash)
        [field_type.first]
      end

      sig { params(property: SchemaRegistry::Property, _prefix: T.nilable(String)).returns(String) }
      def resolve_field_name(property, _prefix)
        property.type_name.to_s.sub('ValueObjects::', '').sub('::', '_').underscore.camelize
      end

      sig { returns(T::Hash[String, T.untyped]) }
      attr_accessor :resolved_types
    end
  end
end
