# frozen_string_literal: true
# typed: strict

require_relative 'capabilities/capability_config'
require_relative 'capability_factory'
require_relative 'relationship'
require_relative 'verb'
require_relative '../schema_registry/schema'

module ResourceRegistry
  # The main class that represents a resource in the system.
  class Resource < T::Struct
    extend T::Sig

    class VerbNotFound < StandardError
    end

    class SchemaNotFound < StandardError
    end

    const :repository_raw, String
    const :description, String, default: ''
    const :capabilities, T::Hash[Symbol, Capabilities::CapabilityConfig], default: {}
    const :relationships, T::Hash[Symbol, Relationship], default: {}
    const :schema, SchemaRegistry::Schema # Output
    const :verbs, T::Hash[Symbol, Verb]

    # FIXME: Solve it with capabilities
    #
    # Certain resources are not paginateable, for example, if a resource
    # entity represents a point on a graph.
    # We should be strict about the semantics of this property, and avoid using
    # it as a hack to avoid having to build pagination into our products
    const :paginateable, T::Boolean, default: true

    sig { returns(String) }
    def path
      @path = T.let(@path, T.nilable(String))
      @path ||= "#{namespace.parameterize}/#{slug}"
    end

    sig { returns(String) }
    def slug
      @slug ||= T.let(name.to_s.parameterize, T.nilable(String))
    end

    sig { returns(Symbol) }
    def identifier
      @identifier ||= T.let(:"#{namespace.underscore}.#{name.to_s.underscore}", T.nilable(Symbol))
    end

    sig { returns(String) }
    def collection_name
      @collection_name ||= T.let(name.to_s.pluralize, T.nilable(String))
    end

    sig { returns(Symbol) }
    def name
      @name ||= T.let(resource_name.underscore.singularize.to_sym, T.nilable(Symbol))
    end

    sig { returns(String) }
    def resource_name
      T.must(repository_raw.split('::').last)
    end

    sig { returns(T::Class[ResourceRegistry::Repositories::Base[T.untyped]]) }
    def repository
      repository_klass = repository_raw.safe_constantize
      raise ArgumentError, "Repository #{repository_raw} not found, did you misspell it?" if repository_klass.nil?

      repository_klass
    end

    sig(:final) { returns(String) }
    def namespace
      namespace = repository_raw.split('::Repositories').first
      return T.must(namespace).sub('::', '') if namespace != to_s

      T.must(repository_raw.split('::').first)
    end

    sig { returns(String) }
    def underscore
      @underscore ||= T.let(identifier.to_s.sub('.', '__'), T.nilable(String))
    end

    sig { returns(String) }
    def camelize
      @camelize ||= T.let(underscore.camelize, T.nilable(String))
    end

    sig { returns(String) }
    def humanize
      name.to_s.humanize
    end

    sig { returns(I18nKeysForResource) }
    def translation
      I18nKeysForResource.new(self)
    end

    sig { params(verb: Symbol, parameters: T.untyped).returns(T::Struct) }
    # Build a DTO instance for the given verb.
    def build_dto(verb, **parameters)
      verb_info = verbs[verb]
      raise VerbNotFound, "#{name} resource doesn't have a ##{verb} verb" if verb_info.nil?

      dto_class = verb_info.dto
      dto_class.new(**parameters)
    end

    # At first glance this method signature appears funkier than a James Brown record.
    #
    # We declare a generic `CapabilityConfig` type parameter, which we then combine
    # in a type union with the public methods declared by the `Capabilities::CapabilityConfig`
    # interface. As such, the `capability` parameter is typed to be any class that includes
    # the `Capabilities::CapabilityConfig` interface.
    # Then, we declare the return type to be a nullable instance of the `CapabilityConfig`
    # type parameter. The result is Sorbet knows that the return type of the method is
    # always the same as the type of the `capability` parameter that the method is called
    # with, so we never need to cast the result. For example, can can do
    #
    # capability = resource.capability(Comments::Capabilities::Commentable)
    #
    # and Sorbet will know that `capability` is an instance of `Comments::Capabilities::Commentable`
    sig do
      type_parameters(:CapabilityConfig)
        .params(
          capability:
            T.all(
              T::Class[T.type_parameter(:CapabilityConfig)],
              # Referencing `ClassMethods` here is not ideal but it seems Sorbet
              # provides no other mechanism to do this
              Capabilities::CapabilityConfig::ClassMethods,
              T::Class[Capabilities::CapabilityConfig]
            )
        )
        .returns(T.nilable(T.type_parameter(:CapabilityConfig)))
    end
    def capability(capability)
      T.unsafe(capabilities[capability.key])
    end

    sig { params(key: Symbol).returns(T.nilable(Capabilities::CapabilityConfig)) }
    def capability_by_key(key)
      capabilities[key]
    end

    sig do
      params(
        feature:
          T.all(
            Capabilities::CapabilityConfig::ClassMethods,
            T::Class[Capabilities::CapabilityConfig]
          )
      ).returns(T::Boolean)
    end
    def capability?(feature)
      !!capabilities[feature.key]
    end

    sig do
      type_parameters(:CapabilityConfig)
        .params(
          feature:
            T.all(
              T::Class[T.type_parameter(:CapabilityConfig)],
              # Referencing ClassMethods here is not ideal but it seems Sorbet
              # provides no other mechanism to do this
              Capabilities::CapabilityConfig::ClassMethods,
              T::Class[Capabilities::CapabilityConfig]
            )
        )
        .returns(T.type_parameter(:CapabilityConfig))
    end
    def capability!(feature)
      T.must(capability(feature))
    rescue TypeError
      raise ArgumentError, "Resource #{name} does not have #{feature} capability"
    end

    sig { returns(T::Array[Verb]) }
    def rpc_verbs
      verbs_except(%i[read update create delete project])
    end

    sig { returns(T::Array[Verb]) }
    def mutation_verbs
      verbs_except(%i[read project])
    end

    sig { params(except: T::Array[Symbol]).returns(T::Array[Verb]) }
    def verbs_except(except)
      verbs.values.filter { |v| except.exclude?(v.id) }
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def dump
      {
        'identifier' => identifier,
        'repository' => repository.to_s,
        'description' => description,
        'relationships' => relationships.values.map(&:dump),
        'capabilities' => capabilities.values.map { |cap| CapabilityFactory.dump(cap) },
        'schema' => schema.dump,
        'verbs' => verbs.values.each_with_object({}) { |verb, memo| memo[verb.id.to_s] = verb.dump }
      }
    end

    sig { params(spec: T::Hash[String, T.untyped]).returns(Resource) }
    def self.load(spec)
      repository = spec['repository'].is_a?(Symbol) ? spec['repository'].to_s : spec['repository']

      new(
        repository_raw: repository,
        description: spec['description'],
        relationships:
          spec['relationships'].each_with_object({}) do |rel_def, memo|
            rel = Relationship.load(rel_def)
            memo[rel.name.to_sym] = rel
          end,
        verbs:
          spec['verbs']
            .values
            .each_with_object({}) do |verb_def, memo|
              verb = Verb.load(verb_def)
              memo[verb.id] = verb
            end,
        capabilities:
          spec['capabilities'].each_with_object({}) do |config, memo|
            cap = CapabilityFactory.load(config)
            memo[cap.class.key] = cap
          end,
        schema: SchemaRegistry::Schema.load(spec['schema']),
        paginateable: spec.fetch('paginateable', true)
      )
    end
  end
end
