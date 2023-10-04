# typed: strict

module ResourceRegistry
  module Graphql
    class FilterConfiguration
      extend T::Sig

      FILTER = T.let('filter'.freeze, String)

      class Filter < T::Struct
        const :filter, T.nilable(T::Hash[Symbol, T::Hash[Symbol, T.untyped]])
      end

      sig { params(field: T.nilable(GraphQL::Schema::Field), resource: Resource).void }
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def self.create_arguments(field, resource)
        unless resource.schema.properties.any?(&:resolvable) ||
                 !resource.schema.additional_filter_fields.empty?
          return
        end

        filter_type = Class.new(GraphQL::Schema::InputObject)
        filter_conditions_type = Class.new(GraphQL::Schema::InputObject)
        filter_conditions_type.graphql_name("#{resource.camelize}FilterConditions")
        filter_type.graphql_name("#{resource.camelize}Filter")
        filter_type.argument('or', [filter_conditions_type], required: false)

        filter_type.description("the filter for the #{resource.collection_name} resource")

        resource.schema.properties.each do |property|
          next unless property.resolvable
          next if property.resolver && !property.resolver&.split&.one?

          add_property(property, filter_type)
          add_property(property, filter_conditions_type)
        end

        resource.schema.additional_filter_fields.each do |filter_field|
          add_field(filter_field, filter_type)
          add_field(filter_field, filter_conditions_type)
        end
        T.unsafe(field).argument(FILTER, filter_type, required: false)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      sig do
        params(data: ActionController::Parameters, schema: SchemaRegistry::Schema).returns(
          T.nilable(Repositories::OutputContexts::Filter)
        )
      end
      def self.filter_dto(data, schema)
        filters = TypedParams[Filter].new.extract!(data).filter

        return nil unless filters

        filter_conditions =
          filters.each.map do |key, value|
            comparator_key = T.must(value.keys.first)
            field_name = key.to_s.underscore
            field = schema.find_additional_filter_field(field_name)

            Repositories::OutputContexts::Filter::FilterCondition.new(
              field: T.must(field&.field || schema.get_resolver_value(field_name)),
              comparator: comparator_key,
              value: value[comparator_key],
              in_memory: field&.in_memory == true
            )
          end
        Repositories::OutputContexts::Filter.new(filters: filter_conditions)
      end

      sig do
        params(
          property: SchemaRegistry::Property,
          type: T.class_of(GraphQL::Schema::InputObject)
        ).void
      end
      private_class_method def self.add_property(property, type)
        type.argument(
          property.name,
          FilterType.filter_type(SchemaTypeToGraph.call(property)),
          required: false
        )
      end

      sig do
        params(
          field: SchemaRegistry::FilterField,
          type: T.class_of(GraphQL::Schema::InputObject)
        ).void
      end
      private_class_method def self.add_field(field, type)
        type.argument(
          field.name,
          FilterType.filter_type(SchemaTypeToGraph.fetch_type(field.type)),
          required: false
        )
      end
    end
  end
end
