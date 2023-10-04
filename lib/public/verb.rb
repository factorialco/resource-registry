# typed: strict

module ResourceRegistry
  class Verb < T::Struct
    extend T::Sig

    const :id, Symbol
    const :dto, T.class_of(T::Struct)
    const :policies, T::Array[T.class_of(Policy)], default: []
    const :event, T.nilable(T.class_of(EventSystem::Event))
    const :summary, T.nilable(String), default: nil
    const :description, T.nilable(String), default: nil
    const :deprecated_on, T.nilable(Date), default: nil
    const :schema, SchemaRegistry::Schema
    const :return_many, T::Boolean, default: false

    sig { returns(Symbol) }
    def schema_identifier
      @schema_identifier ||= T.let("#{id.to_s.underscore}_dto".to_sym, T.nilable(Symbol))
    end

    sig { returns(T::Boolean) }
    def deprecated?
      return false if deprecated_on.blank?

      T.must(deprecated_on) < Time.zone.today
    end

    sig { returns(T::Boolean) }
    def mutation?
      destroy? || update? || create?
    end

    sig { returns(T::Boolean) }
    def get?
      %i[find show read].include? id
    end

    sig { returns(T::Boolean) }
    def destroy?
      id == :delete
    end

    sig { returns(T::Boolean) }
    def update?
      id == :update
    end

    sig { returns(T::Boolean) }
    def create?
      id == :create
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def dump
      {}.tap do |result|
        result['id'] = id
        result['dto'] = dto.to_s
        result['policies'] = policies.map(&:name)
        result['schema'] = schema.dump
        result['return_many'] = return_many
      end
    end

    sig { params(spec: T.untyped).returns(Verb) }
    def self.load(spec)
      id = spec['id']
      raise ArgumentError, 'Missing verb ID!' if id.nil?
      dto = spec['dto']
      raise ArgumentError, "DTO for verb #{spec['id']} not found" if dto.nil?
      policies =
        spec['policies'].map do |policy_name|
          policy_class = policy_name.safe_constantize
          if policy_class.nil?
            raise ArgumentError, "Policy class #{policy_name} for verb #{spec['id']} not found"
          end
          policy_class
        end

      new(
        id: id,
        dto: dto.safe_constantize,
        policies: policies,
        schema: SchemaRegistry::Schema.load(spec['schema']),
        return_many: spec['return_many'],
        description: spec['description']
      )
    end
  end
end
