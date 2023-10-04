# typed: strict

module ResourceRegistry
  class InferResources
    extend T::Sig

    DEFAULT_CAPABILITIES =
      T.let(
        {
          Capability::Rest.serialize => Capabilities::Rest.new,
          Capability::Graphql.serialize => Capabilities::Graphql.new
        }.freeze,
        T::Hash[Symbol, Capabilities::CapabilityConfig]
      )

    sig { void }
    def initialize
      @schema_generator = T.let(SchemaGenerator.new, SchemaGenerator)
    end

    sig { returns(T::Array[Resource]) }
    def call
      # FIXME: Change to use Class#subclasses once we upgrade to Ruby 3.1
      compatible_repositories =
        (Repositories::BaseOld.descendants + Repositories::Base.descendants).sort_by!(&:name)

      compatible_repositories.filter_map { |repo| generate_resource_from_repository(repo) }
    end

    private

    sig { returns(SchemaGenerator) }
    attr_reader :schema_generator

    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    sig do
      params(
        repository: T.any(T.class_of(::Repositories::Base), T.class_of(::Repositories::BaseOld))
      ).returns(T.nilable(Resource))
    end
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

          returns_many =
            signature.return_type.try(:raw_type)&.ancestors&.include?(::Repositories::ReadResult)

          definition = SchemaRegistry::GenerateFromStruct.new(struct_klass: dto_klass).call
          verb_schema =
            SchemaRegistry::JsonSchemaMapper.new(
              namespace: repository.namespace,
              definition: definition
            ).call

          memo[verb] = ResourceRegistry::Verb.new(
            id: verb,
            dto: dto_klass,
            schema: verb_schema,
            return_many: returns_many || false
          )
        rescue NoMethodError
          next # FIXME: Some sorbet kwarg_types have no raw_type...
        end

      ResourceRegistry::Resource.new(
        repository: repository,
        schema: schema,
        verbs: verbs,
        capabilities: {
          Capability::Rest.serialize => Capabilities::Rest.new,
          Capability::Graphql.serialize => Capabilities::Graphql.new
        },
        relationships: {
        },
        traits: {
        }
      )
    end
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  end
end
