# typed: strict

class ResourceRegistry::Initializer
  extend T::Sig

  sig do
    returns(
      [
        ResourceRegistry::Registry,
        SchemaRegistry::Registry,
        T.class_of(GraphQL::Schema),
        ResourceRegistry::OverridesLoader
      ]
    )
  end
  def call
    register_resources!
    [resource_registry, schema_registry, graphql_schema, overrides_loader]
  end

  private

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
  def register_resources! # rubocop:disable Metrics/AbcSize
    resources.each do |res|
      schema_registry.register(res.schema)

      res.verbs.values.each { |v| schema_registry.register(v.schema) }
    end

    # TODO: kill all this custom schema loading. Instead, just include schema overrides
    # in the resource yml file. We are already doing this across the app, so we have a
    # mix of schema definitions in resource.ymls and schema.ymls
    paths =
      ::Rails::Engine
        .subclasses
        .map(&:instance)
        .filter { |instance| instance.paths.path.dirname.to_s.include?('components') }
        .map do |instance|
          pathname = instance.paths.path
          [
            instance.class.module_parent.to_s,
            File.join(pathname.dirname, pathname.basename, 'app', 'schemas').to_s
          ]
        end

    SchemaRegistry::SchemaLoader.new(schema_registry: schema_registry).load(paths)

    schema_registry
  end

  sig { returns(T.class_of(GraphQL::Schema)) }
  def graphql_schema
    @graphql_schema ||=
      T.let(
        ResourceRegistry::Graphql::GraphqlSchemaGenerator.new(
          resources:
            resource_registry.fetch_with_capabilities(ResourceRegistry::Capability::Graphql)
        ).call,
        T.nilable(T.class_of(GraphQL::Schema))
      )
  end

  sig { returns(T::Array[ResourceRegistry::Resource]) }
  def resources
    @resources ||=
      T.let(
        begin
          # Eager loading repository classes to autodiscover resources
          RepositoryWarmer.new.call

          inferred_resources = ResourceRegistry::InferResources.new.call

          overriden_resources = inferred_resources.map(&:dump).map { |res| apply_override(res) }

          overriden_resources
            .map { |res_def| ResourceRegistry::Resource.load(res_def) }
            .sort_by(&:path)
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
    @overrides ||=
      T.let(ResourceRegistry::OverridesLoader.new, T.nilable(ResourceRegistry::OverridesLoader))
  end
end
