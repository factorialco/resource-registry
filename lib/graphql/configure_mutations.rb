# typed: strict

module ResourceRegistry
  module Graphql
    class ConfigureMutations
      extend T::Sig

      sig do
        params(
          resolved_types: T::Hash[String, T.untyped],
          resource: Resource,
          root_mutation: T.class_of(BaseObject),
          type: T.class_of(BaseObject)
        ).void
      end
      def initialize(resolved_types, resource, root_mutation, type)
        @resolved_types = resolved_types
        @resource = resource
        @root_mutation = root_mutation
        @type = type
      end

      sig { void }
      def call
        # `resource` is passed down the methods since they define annonymous
        # Classes and thus don't have access to the attr_reader
        configure_mutations(resource, type)
      end

      sig { returns(T::Hash[String, T.untyped]) }
      attr_accessor :resolved_types

      private

      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/BlockLength
      # rubocop:disable Metrics/MethodLength
      sig { params(resource: Resource, type: T.class_of(BaseObject)).void }
      # rubocop:disable Metrics/CyclomaticComplexity
      def configure_mutations(resource, type)
        resource.mutation_verbs.each do |verb|
          mutation_schema = verb.schema

          mutation = Class.new(BaseMutation)
          mutation_name = "#{verb.id}_#{resource.namespace}_#{resource.name}"
          camelized_name = mutation_name.camelize
          mutation.graphql_name(camelized_name)

          mutation.field :errors, [::ResourceRegistry::Graphql::MutationErrorType], null: false

          if verb.return_many
            mutation.field resource.collection_name, [type], null: true
          else
            mutation.field resource.name, type, null: true
          end

          mutation_schema.properties.each do |property|
            argument = SchemaArgumentResolver.new(resolved_types).call(property, camelized_name)

            mutation.argument(argument.name, argument.type, required: argument.required)
          end

          mutation.define_method(:resolve) do |**kwargs|
            policy_context = public_send(:context)[:policy_context]
            repository = resource.repository.new(policy_context: policy_context)

            ResourceRegistry::Tracer.trace_repository(repository, verb: verb.id.to_s) do
              outcome =
                repository.public_send(
                  verb.id,
                  dto: ResourceStructBuilder.new(verb.dto).build(kwargs.to_h)
                )

              result = {}
              result[:errors] = []

              if verb.return_many
                if outcome.entities.error?
                  return(
                    {
                      errors: [
                        SimpleError.new(
                          type: outcome.entities.error.type.serialize.to_s,
                          message: outcome.entities.error.to_s
                        )
                      ]
                    }
                  )
                end

                result[resource.collection_name] = outcome.entities.value.map do |v|
                  repository.serialize(entity: v).with_indifferent_access
                end

                return result
              end

              if outcome.error?
                errors =
                  if outcome.error.messages
                    outcome.error.messages.map do |(field, messages)|
                      StructuredError.new(field: field.to_s, messages: messages)
                    end
                  else
                    [
                      SimpleError.new(
                        type: outcome.error.type.serialize.to_s,
                        message: ErrorHandler.message_for(outcome.error.type)
                      )
                    ]
                  end

                return { errors: errors }
              end

              result[resource.name] = repository.serialize(
                entity: outcome.value
              ).with_indifferent_access

              result
            end
          end

          lower_camelized_name = (camelized_name[0].downcase + camelized_name[1..-1]).to_sym

          root_mutation.field(lower_camelized_name, mutation: mutation, null: false)
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/BlockLength
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity

      sig { returns(Resource) }
      attr_reader :resource

      sig { returns(T.class_of(BaseObject)) }
      attr_reader :root_mutation

      sig { returns(T.class_of(BaseObject)) }
      attr_reader :type
    end
  end
end
