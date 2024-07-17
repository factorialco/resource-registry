# typed: strict

module ResourceRegistry
  class Relationship < T::Struct
    extend T::Sig

    const :name, String
    const :resource_id, Symbol
    const :field, Symbol
    const :primary_key, Symbol, default: :id
    const :type, RelationshipType
    const :fixed_dto_params, T.nilable(T::Hash[String, T.untyped])
    const :optional, T::Boolean

    # Are there multiple resources in the other side of the relationship?
    delegate :many_cardinality?, to: :type

    sig { returns(T::Hash[String, T.untyped]) }
    def dump
      {}.tap do |result|
        result['name'] = name
        result['resource_id'] = resource_id
        result['primary_key'] = primary_key
        result['field'] = field
        result['type'] = type.serialize
        result['optional'] = optional
        result['fixed_dto_params'] = fixed_dto_params
      end
    end

    sig { params(spec: T::Hash[String, T.untyped]).returns(Relationship) }
    def self.load(spec)
      type = RelationshipTypeFactory.from_spec(spec)

      new(
        name: type.name,
        resource_id: type.resource_id,
        field: type.field,
        primary_key: type.primary_key,
        type: type,
        fixed_dto_params: spec['fixed_dto_params'],
        optional: !spec['optional'].to_s.casecmp('false').zero?
      )
    end

    sig { params(resource_registry: Registry).returns(Resource) }
    def target_resource!(resource_registry: Rails.configuration.resource_registry)
      resource_registry.fetch!(resource_id.to_s)
    end

    # We provide this in the dataloader, we encourage not to perform joins in
    # frontend, so we skip ids to be exposed.
    # FIXME: Review if this belongs to this layer or is coupled to GraphQL
    sig { params(argument: String).returns(T::Boolean) }
    def should_skip_argument?(argument)
      return true if fixed_dto_params&.key?(argument)

      type.should_skip_argument?(argument, self)
    end

    # The field used to define the left side of a relationship. This is the
    # field that it will be passed to the next resolver to fetch the data.
    sig { returns(T.nilable(Symbol)) }
    def reference_id
      type.reference_id(self)
    end

    sig { returns(T::Boolean) }
    def optional?
      case type
      when ResourceRegistry::RelationshipTypes::HasMany,
           ResourceRegistry::RelationshipTypes::HasManyThrough
        false
      else
        optional
      end
    end
  end
end
