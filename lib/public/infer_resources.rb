# frozen_string_literal: true
# typed: false

require_relative '../schema_generator'
require_relative 'repositories/base'

module ResourceRegistry
  class InferResources
    extend T::Sig

    sig { void }
    def initialize
      @schema_generator = T.let(SchemaGenerator.new, SchemaGenerator)
    end

    sig { params(repositories: T::Array[ResourceRegistry::Repositories::Base[T.untyped]]).returns(T::Array[Resource]) }
    def call(repositories:)
      repositories.filter_map { |repo| generate_resource_from_repository(repo) }
    end

    private

    sig { returns(SchemaGenerator) }
    attr_reader :schema_generator

    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    sig { params(repository: T.class_of(ResourceRegistry::Repositories::Base)).returns(T.nilable(Resource)) }
    def generate_resource_from_repository(repository)
      schema = schema_generator.generate(repository: repository)

      unless schema
        puts "Unable to infer schema for #{repository}" if Rails.env.development?
        return
      end

      repo_verbs, verbs_without_hooks =
        repository
        .public_instance_methods(false)
        .partition { |method| !method.end_with?('__without_hooks') }

      verbs =
        repo_verbs.each_with_object({}) do |verb, memo|
          verb_for_signature =
            verbs_without_hooks.find { |vwh| vwh == :"#{verb}__without_hooks" } || verb

          signature = T::Utils.signature_for_instance_method(repository, verb_for_signature)
          dto_def = signature.kwarg_types[:dto]
          dto_klass = dto_def&.raw_type unless dto_def.is_a?(T::Types::TypedHash) # FIXME: What we should do with this?

          next unless dto_klass # FIXME: Throw an exception?

          return_type = (signature.return_type[:raw_type] if signature.return_type.respond_to?(:raw_type))

          returns_many =
            return_type&.ancestors&.include?(::Repositories::ReadResult)

          definition = SchemaRegistry::GenerateFromStruct.new(struct_klass: dto_klass).call
          verb_schema =
            SchemaRegistry::JsonSchemaMapper.new(
              namespace: repository.namespace,
              definition: definition
            ).call

          memo[verb] = ResourceRegistry::Verb.new(
            id: verb,
            dto_raw: dto_klass.to_s,
            schema: verb_schema,
            return_many: returns_many || false
          )
        end

      ResourceRegistry::Resource.new(
        repository_raw: repository.to_s,
        schema: schema,
        verbs: verbs,
        capabilities: {},
        relationships: {}
      )
    end
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  end
end
