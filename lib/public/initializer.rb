# typed: false

require_relative 'infer_resources'
require_relative 'overrides_loader'
require_relative 'registry'
require_relative 'repository_warmer'
require_relative 'resource'

require_relative '../schema_registry/schema_loader'
require_relative '../schema_registry/registry'

module ResourceRegistry
  class Initializer
    extend T::Sig

    sig { params(repository_base_klass: T::Class[ResourceRegistry::Repositories::Base[T.untyped]]).void }
    def initialize(repository_base_klass: ResourceRegistry::Repositories::Base)
      @repository_base_klass = repository_base_klass
    end

    sig do
      returns(
        [ResourceRegistry::Registry, SchemaRegistry::Registry, ResourceRegistry::OverridesLoader]
      )
    end
    def call
      register_resources!
      [resource_registry, schema_registry, overrides_loader]
    end

    sig { void }
    def warm!
      # Eager loading repository classes to autodiscover resources
      RepositoryWarmer.new.call
    end

    private

    attr_reader :repository_base_klass

    sig { returns(ResourceRegistry::Registry) }
    def resource_registry
      @resource_registry ||=
        T.let(
          ResourceRegistry::Registry.new(resources: resources),
          T.nilable(ResourceRegistry::Registry)
        )
    end

    sig { returns(SchemaRegistry::Registry) }
    def schema_registry
      @schema_registry ||= T.let(SchemaRegistry::Registry.new, T.nilable(SchemaRegistry::Registry))
    end

    sig { void }
    # Registering Resource schemas to SchemaRegistry
    def register_resources!
      resources.each do |res|
        schema_registry.register(res.schema)

        res.verbs.values.each { |v| schema_registry.register(v.schema) }
      end

      schema_registry
    end

    sig { returns(T::Array[ResourceRegistry::Resource]) }
    def resources
      @resources ||=
        T.let(
          begin
            if ENV.fetch('ENABLE_RR_CACHE', 'false') == 'true'
              puts '-> Loading RR resources from cache'

              ResourceRegistry::LoadResourcesFromCache.new.call
            else
              puts '-> Loading RR resources from inference system'
              inferred_resources = ResourceRegistry::InferResources.new.call(repositories: repository_base_klass.subclasses.sort_by!(&:name))

              overriden_resources = inferred_resources.map(&:dump).map { |res| apply_override(res) }

              overriden_resources
                .map { |res_def| ResourceRegistry::Resource.load(res_def) }
                .sort_by(&:path)
            end
          end,
          T.nilable(T::Array[ResourceRegistry::Resource])
        )
    end

    sig { params(resource: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
    def apply_override(resource)
      any_match =
        overrides_loader.overrides.find do |override_def|
          override_def['identifier'] == resource['identifier']
        end

      return resource unless any_match

      resource.deep_merge(any_match)
    end

    sig { returns(ResourceRegistry::OverridesLoader) }
    def overrides_loader
      @overrides_loader ||=
        T.let(ResourceRegistry::OverridesLoader.new, T.nilable(ResourceRegistry::OverridesLoader))
    end
  end
end
