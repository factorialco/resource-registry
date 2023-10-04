# typed: strict

module ResourceRegistry
  module Graphql
    class ResourceQuery
      extend T::Sig

      AllTypes =
        T.type_alias do
          T.any(
            String,
            Integer,
            Float,
            T::Boolean,
            ApolloUploadServer::Wrappers::UploadedFile,
            T::Hash[String, T.untyped]
          )
        end
      ValueTypes = T.type_alias { T.nilable(T.any(AllTypes, T::Hash[String, AllTypes])) }
      Variables =
        T.type_alias { T.nilable(T::Hash[String, T.any(ValueTypes, T::Array[ValueTypes])]) }

      sig do
        params(
          query: String,
          policy_context: Permissions::PolicyContext,
          channel: T.nilable(GraphqlChannel),
          operation_name: T.nilable(String),
          variables: Variables,
          resources: T::Array[ResourceRegistry::Resource],
          skip_pagination: T::Boolean
        ).void
      end
      def initialize( # rubocop:disable Metrics/ParameterLists
        query,
        policy_context:,
        channel: nil,
        operation_name: nil,
        variables: {},
        resources: Rails.configuration.resource_registry.fetch_with_capabilities(
          ::ResourceRegistry::Capability::Graphql
        ),
        skip_pagination: false
      )
        @query = query
        @channel = channel
        @policy_context = policy_context
        @operation_name = operation_name
        @variables = variables
        @resources = resources
        @skip_pagination = skip_pagination
      end

      sig { returns(T.untyped) }
      def call
        access = policy_context.respond_to?(:access) ? T.unsafe(policy_context).access : nil

        schema.execute(
          query,
          variables: variables,
          context: {
            channel: channel,
            access_id: access&.id,
            operation_name: operation_name,
            company_id: access&.company_id,
            policy_context: policy_context,
            skip_pagination: skip_pagination
          }
        ).to_h
      rescue SchemaRegistry::Registry::SchemaNotFound => e
        { errors: e.message }
      end

      private

      sig { returns(String) }
      attr_reader :query

      sig { returns(Variables) }
      attr_reader :variables

      sig { returns(Permissions::PolicyContext) }
      attr_reader :policy_context

      sig { returns(T::Array[ResourceRegistry::Resource]) }
      attr_reader :resources

      sig { returns(T::Boolean) }
      attr_reader :skip_pagination

      sig { returns(T.nilable(String)) }
      attr_reader :operation_name

      sig { returns(T.nilable(GraphqlChannel)) }
      attr_reader :channel

      sig { returns(T.class_of(GraphQL::Schema)) }
      def schema
        @schema ||=
          T.let(Rails.configuration.graphql_schema, T.nilable(T.class_of(GraphQL::Schema)))
      end
    end
  end
end
