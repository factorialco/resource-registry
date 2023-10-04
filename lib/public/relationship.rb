# typed: strict

module ResourceRegistry
  class Relationship < T::Struct
    class Type < T::Enum
      enums do
        HasMany = new('has_many') # field is hosted in the destination entity
        HasOne = new('has_one') # field is hosted in the destination entity
        BelongsTo = new('belongs_to') # field is hosted in the origin entity
        HasManyThrough = new('has_many_through') # field is hosted in the origin entity as an array
      end
    end

    extend T::Sig

    const :name, String
    const :resource_id, Symbol
    const :field, Symbol
    const :primary_key, Symbol, default: :id
    const :type, Type
    const :fixed_dto_params, T.nilable(T::Hash[String, T.untyped])
    const :optional, T::Boolean

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
      new(
        name: spec['name'],
        resource_id: spec['resource_id'],
        field: spec['field'],
        primary_key: spec['primary_key'] || :id,
        type: Type.deserialize(spec['type']),
        fixed_dto_params: spec['fixed_dto_params'],
        optional: !spec['optional'].to_s.casecmp('false').zero?
      )
    end

    sig { params(resource_registry: Registry).returns(Resource) }
    def target_resource!(resource_registry: Rails.configuration.resource_registry)
      resource_registry.fetch!(resource_id.to_s)
    end
  end
end
