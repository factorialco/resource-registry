# rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
# typed: strict

module ResourceRegistry
  module Graphql
    class GraphqlRepositorySource < GraphQL::Dataloader::Source
      extend T::Sig

      class ForeignKeyParamNotDefined < StandardError
      end

      sig do
        params(
          resource: Resource,
          inst_context: GraphQL::Query::Context,
          rel: Relationship,
          provided_arguments: T::Hash[Symbol, T.untyped],
          connection: T::Boolean
        ).void
      end
      def initialize(resource, inst_context, rel, provided_arguments, connection: false)
        @resource = resource
        @inst_context = inst_context
        @policy_context = T.let(inst_context[:policy_context], Permissions::PolicyContext)
        @rel = rel
        @connection = connection
        @provided_arguments = provided_arguments
      end

      sig do
        params(ids: T::Array[String]).returns(
          T::Array[
            T.nilable(T.any(T::Hash[String, T.untyped], T::Array[T::Hash[String, T.untyped]]))
          ]
        )
      end
      def fetch(ids)
        res = resolved(ids).map(&:serialize)

        case rel.type
        when ResourceRegistry::Relationship::Type::HasOne
          indexed_res = res.index_by { |resource| resource[rel.field.to_s] }
          ids.map { |id| indexed_res[id] }
        when ResourceRegistry::Relationship::Type::HasMany
          indexed_res = res.group_by { |r| r[rel.field.to_s] }
          ids.map { |id| indexed_res[id] || [] }
        when ResourceRegistry::Relationship::Type::BelongsTo
          indexed_res = res.index_by { |resource| resource['id'] }
          ids.map { |id| indexed_res[id] }
        when ResourceRegistry::Relationship::Type::HasManyThrough
          ids.map { |many_ids| res.filter { |r| many_ids.include?(r['id']) } }
        end
      end

      private

      sig { returns(Resource) }
      attr_reader :resource

      sig { returns(Permissions::PolicyContext) }
      attr_reader :policy_context

      sig { returns(Relationship) }
      attr_reader :rel

      sig { returns(T::Boolean) }
      attr_reader :connection

      sig { returns(T::Hash[Symbol, T.untyped]) }
      attr_reader :provided_arguments

      sig { returns(GraphQL::Query::Context) }
      attr_reader :inst_context

      sig { params(ids: T::Array[String]).returns(T::Array[T.all(T::Struct, Identifiable)]) }
      def resolved(ids)
        read_verb = resource.verbs[:read]

        return [] unless read_verb

        repository = resource.repository.new(policy_context: policy_context)

        dto = provided_arguments
        dto.merge!(T.must(rel.fixed_dto_params).symbolize_keys) if rel.fixed_dto_params

        case rel.type
        when ResourceRegistry::Relationship::Type::HasOne,
             ResourceRegistry::Relationship::Type::HasMany
          dto[rel.field.to_s.pluralize.to_sym] = ids.compact
        when ResourceRegistry::Relationship::Type::BelongsTo
          dto[:ids] = ids.compact
        when ResourceRegistry::Relationship::Type::HasManyThrough
          dto[:ids] = ids.flatten.compact.uniq
        end

        ResourceRegistry::Tracer.trace_repository(repository, verb: 'read', collection: true) do
          if connection
            case repository
            when ::Repositories::BaseOld
              raise NotImplementedError, 'Connections are not implemented for BaseOld repositories'
            when ::Repositories::Base
              ContextConnection.new(
                repository: repository,
                dto: read_verb.dto.new(dto),
                schema: resource.schema,
                inst_context: inst_context
              ).result
            end
          else
            result = repository.read(dto: read_verb.dto.new(dto))

            case repository
            when Repositories::BaseOld
              T.cast(result, Outcome[T::Array[T.untyped]]).unwrap!
            when Repositories::Base
              T.cast(result, Repositories::ReadResult[T.untyped]).entities.unwrap!
            end
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
