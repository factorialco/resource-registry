# typed: strict

module ResourceRegistry
  module Graphql
    class ConfigureReadQueries
      extend T::Sig

      sig do
        params(
          resolved_types: T::Hash[String, T.untyped],
          resource: Resource,
          query: T.class_of(BaseObject),
          type: T.class_of(BaseObject)
        ).void
      end
      def initialize(resolved_types, resource, query, type)
        @resolved_types = resolved_types
        @resource = resource
        @query = query
        @type = type
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      sig { void }
      def call
        read_verb = resource.verbs[:read]

        return unless read_verb

        # Setting surrounding context for blocks so they can access resource
        outer_resource = resource

        read_schema = read_verb.schema
        query.field(
          resource.collection_name,
          [type],
          null: false,
          deprecation_reason:
            "Please favor `#{resource.collection_name.camelize(:lower)}Connection` over using this field as connections come with built-in pagination. This will help you build more performant user interfaces."
        ) do |f|
          read_schema.properties.each { |property| T.unsafe(self).resolve_argument(f, property) }
        end
        query.define_method(resource.collection_name) do |**kwargs|
          inst = T.cast(self, BaseObject)
          policy_context = inst.context[:policy_context]
          repository = outer_resource.repository.new(policy_context: policy_context)

          dto = ConfigureReadQueries.create_dto(read_verb.dto, kwargs)

          ResourceRegistry::Tracer.trace_repository(repository, verb: 'read') do
            raw_results =
              case repository
              when ::Repositories::BaseOld
                repository.read(dto: dto).unwrap!
              when ::Repositories::Base
                repository.read(dto: dto).entities.unwrap!
              end

            raw_results.map { |res| repository.serialize(entity: res).with_indifferent_access }
          end
        end

        query.field(resource.name, type, null: true, directives: { FinderDirective => {} }) do |f|
          T.unsafe(f).argument(:id, Integer, 'Item ID')
        end

        query.define_method(resource.name) do |**kwargs|
          inst = T.cast(self, BaseObject)
          policy_context = inst.context[:policy_context]

          # FIXME: Standarize resource ID providing
          id = kwargs[:id].to_i

          repository = outer_resource.repository.new(policy_context: policy_context)

          # FIXME: Handle empty collection errors
          ResourceRegistry::Tracer.trace_repository(repository, verb: 'read') do
            raw_result =
              case repository
              when ::Repositories::BaseOld
                repository.read(dto: read_verb.dto.new(ids: [id])).unwrap!.first
              when ::Repositories::Base
                repository.read(dto: read_verb.dto.new(ids: [id])).entities.unwrap!.first
              end

            return nil unless raw_result

            repository.serialize(entity: raw_result).with_indifferent_access
          end
        end

        ConfigureContexts.create_context_connection(
          resolved_types: resolved_types,
          query: query,
          type: type,
          resource: outer_resource,
          read_verb: read_verb
        )
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      sig { params(field: T.untyped, property: SchemaRegistry::Property).void }
      def resolve_argument(field, property)
        argument =
          SchemaArgumentResolver.new(T.unsafe(self).resolved_types).call(
            property,
            T.unsafe(self).resource.collection_name,
            T.unsafe(self).resource.verbs[:read].id
          )

        if property.default.nil?
          T.unsafe(field).argument(argument.name, argument.type, required: argument.required)
        else
          T.unsafe(field).argument(
            argument.name,
            argument.type,
            required: argument.required,
            default_value: property.default
          )
        end
      end

      sig do
        params(dto: T.class_of(T::Struct), kwargs: T::Hash[T.untyped, T.untyped]).returns(T.untyped)
      end
      def self.create_dto(dto, kwargs)
        # FIXME: This code is repeated in ConfigureContexts
        ResourceStructBuilder.new(dto).build(kwargs)
      end

      sig { returns(Resource) }
      attr_reader :resource

      sig { returns(T::Hash[String, T.untyped]) }
      attr_accessor :resolved_types

      private

      sig { returns(T.class_of(BaseObject)) }
      attr_reader :query

      sig { returns(T.class_of(BaseObject)) }
      attr_reader :type
    end
  end
end
