# Resource Registry

A declarative resource-oriented registry for a generic usage.

## What is this?

Resource Registry allows you to define resources and their actions in a
declarative way. Leaving the imperative implementation of the business logic
behavior to the user. (Using the repository pattern). And allowing to create
generic features for the whole catalog of resources at once.

This is very useful to scale big projects codebases in order to implement
generic features for the whole catalog or resources.

It uses few basic concepts to construct this registry:

## Anatomy of a resource, `ResourceRegistry::Resource`

A resource represents the centric part of this library. They should contain and
provide all the necessary information to generate features around. This
includes Capabilities, Repository, verbs and Entity/DTOs schemas.

An example of a resource:

```ruby
class GraphqlCapability < T::Struct
  extend T::Sig

  include ResourceRegistry::Capabilities::CapabilityConfig

  sig { override.returns(Symbol) }
  def self.key
    :void_capability
  end
end

ResourceRegistry::Resource.new(
  repository_raw: YourRepositoryClass.to_s,
  capabilities: {
    graphql: GraphqlCapability.new
  },
    verbs: {
      read: ResourceRegistry::Verb.new(
        id: verb,
        dto_raw: dto_klass.to_s,
        schema: read_verb_schema,
        return_many: true
      )
    },
  schema: SchemaRegistry::Schema.new(
    name: 'employees',
    namespace: 'employees',
    properties: [
      SchemaRegistry::Property.new(
        name: 'id',
        types: [SchemaRegistry::PropertyType::String],
        required: true
      ),
      SchemaRegistry::Property.new(
        name: 'fullName',
        types: [SchemaRegistry::PropertyType::String],
        required: true
      )
    ]
  )
)
```

## The registry itself, `ResourceRegistry::Registry`

Gives you access to the whole library using the following API:

```ruby
registry = ResourceRegistry::Registry.new

# Fetch a resource by its identifier
registry.fetch(:employees)

# Fetch all resources
registry.fetch_rall
```

## What brings this gem to the table?

- Schema registry for resources, maybe we can infere them from entities
- Relate events to resources actions (CRUD and not CRUD)

## Install

Add the following lines in your Gemfile:

```ruby
gem 'resource_registry', github: 'factorialco/resource-registry'
```

And run `bundle install`

## Setting up your first resources

TODO

## Similar projects

Check [ash](https://ash-hq.org/) for a similar and much mature approach applied to Elixir apps.
