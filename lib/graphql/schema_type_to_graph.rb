# typed: strict

module ResourceRegistry
  module Graphql
    class SchemaTypeToGraph
      extend T::Sig

      sig do
        params(
          property: SchemaRegistry::Property,
          prefix: T.nilable(String),
          resolved_types: T::Hash[String, T.untyped]
        ).returns(T.untyped) # GraphQL types forces me to type all posibilities which is a PITA
      end
      def self.call(property, prefix = nil, resolved_types = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
        type = property.types.first
        if property_array?(type, property)
          types = property.items.map { |t| call(t, prefix) }
          return types
        end

        graphql_name = "#{property.type_name&.gsub('::', '')}Enum"

        enum_values = property.enum_values
        if enum_values.present?
          invalid_enum =
            enum_values.any? { |val| val.include?('-') || val.blank? || val.include?(' ') }

          if invalid_enum
            Rails.logger.warn "#{graphql_name} has invalid enum values, skipping enum generation. Change '-', or ' ' to '_', or remove blank values."
          else
            return resolved_types[graphql_name] if resolved_types.key?(graphql_name)

            type = Class.new(GraphQL::Schema::Enum)
            type.graphql_name(graphql_name)
            property.enum_values&.each { |value| type.value(value.parameterize(separator: '_')) }
            resolved_types[graphql_name] = type
            return type
          end
        end

        fetch_type(type)
      end

      TYPE_CONVERSIONS =
        T.let(
          {
            SchemaRegistry::PropertyType::Integer => ::GraphQL::Types::Int,
            SchemaRegistry::PropertyType::BigInteger => ::GraphQL::Types::BigInt,
            SchemaRegistry::PropertyType::Number => ::GraphQL::Types::Float,
            SchemaRegistry::PropertyType::Boolean => ::GraphQL::Types::Boolean,
            SchemaRegistry::PropertyType::File => ::ResourceRegistry::Graphql::FileType,
            SchemaRegistry::PropertyType::Date => ::GraphQL::Types::ISO8601Date,
            SchemaRegistry::PropertyType::Time => ::GraphQL::Types::ISO8601DateTime
          }.freeze,
          T::Hash[T.nilable(SchemaRegistry::PropertyType), GraphQL::Types]
        )

      sig { params(type: T.nilable(SchemaRegistry::PropertyType)).returns(T.untyped) }
      def self.fetch_type(type)
        TYPE_CONVERSIONS.fetch(type, ::GraphQL::Types::String)
      end

      sig do
        params(
          type: T.nilable(SchemaRegistry::PropertyType),
          property: SchemaRegistry::Property
        ).returns(T::Boolean)
      end
      def self.property_array?(type, property)
        property.items.any? && type == SchemaRegistry::PropertyType::Array
      end
    end
  end
end
