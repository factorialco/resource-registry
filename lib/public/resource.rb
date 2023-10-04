# typed: strict

module ResourceRegistry
  class Resource < T::Struct
    extend T::Sig

    class VerbNotFound < StandardError
    end
    class SchemaNotFound < StandardError
    end

    const :repository, T.any(T.class_of(Repositories::BaseOld), T.class_of(Repositories::Base))
    const :description, String, default: ''
    const :capabilities, T::Hash[Symbol, Capabilities::CapabilityConfig], default: {}
    const :relationships, T::Hash[Symbol, Relationship], default: {}
    const :schema, SchemaRegistry::Schema # Output
    const :verbs, T::Hash[Symbol, Verb]
    const :traits, T::Hash[String, T.untyped], default: {}

    sig { returns(T::Array[T.class_of(EventSystem::Event)]) }
    def public_events
      @public_events = T.let([], T.nilable(T::Array[T.class_of(EventSystem::Event)]))
      @public_events ||= verbs.values.filter_map(&:event)
    end

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
      @identifier ||=
        T.let("#{namespace.underscore}.#{name.to_s.underscore}".to_sym, T.nilable(Symbol))
    end

    sig { returns(String) }
    def collection_name
      @collection_name ||= T.let(name.to_s.pluralize, T.nilable(String))
    end

    sig { returns(Symbol) }
    def name
      @name ||= T.let(repository.resource_name.underscore.singularize.to_sym, T.nilable(Symbol))
    end

    delegate :namespace, to: :repository

    sig { returns(String) }
    def underscore
      @underscore ||= T.let(identifier.to_s.sub('.', '__'), T.nilable(String))
    end

    sig { returns(String) }
    def camelize
      @camelize ||= T.let(underscore.camelize, T.nilable(String))
    end

    sig { params(verb_id: Symbol).returns(T::Array[T.class_of(Policy)]) }
    def policies_for_verb(verb_id)
      policies = verbs[verb_id]&.policies || []

      return policies unless policies.empty?

      Rails.configuration.permissions_registry.fetch_policy_for_verb(identifier, verb_id)
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

    sig { params(feature: Capability).returns(T.nilable(Capabilities::CapabilityConfig)) }
    def capability(feature)
      capabilities[feature.serialize]
    end

    sig { params(feature: Capability).returns(T::Boolean) }
    def capability?(feature)
      capability(feature) != nil
    end

    sig { params(feature: Capability).returns(Capabilities::CapabilityConfig) }
    def capability!(feature)
      T.must(capability(feature))
    end

    sig { returns(T::Array[Verb]) }
    def rpc_verbs
      verbs_except(%i[read update create project])
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
        'repository' => repository.to_s.to_sym,
        'description' => description,
        'relationships' => relationships.values.map(&:dump),
        'capabilities' => capabilities.values.map { |cap| Capability.dump(cap) },
        'schema' => schema.dump,
        'verbs' => verbs.values.each_with_object({}) { |verb, memo| memo[verb.id.to_s] = verb.dump }
      }
    end

    sig { params(spec: T::Hash[String, T.untyped]).returns(Resource) }
    def self.load(spec)
      new(
        repository: spec['repository'].to_s.safe_constantize,
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
            cap = Capability.load(config)
            memo[cap.key] = cap
          end,
        schema: SchemaRegistry::Schema.load(spec['schema']),
        traits: spec['traits'] || {}
      )
    end
  end
end
