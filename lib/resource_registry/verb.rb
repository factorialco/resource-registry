# frozen_string_literal: true
# typed: strict

require_relative "../schema_registry/schema"

module ResourceRegistry
  # This is the representation of a verb over a resource. Each resource can
  # have multiple verbs that should be exposed by its repository
  class Verb < T::Struct
    extend T::Sig

    DtoClassNotFound = Class.new(StandardError)

    const :id, Symbol
    const :dto_raw, String
    const :summary, T.nilable(String), default: nil
    const :description, T.nilable(String), default: nil
    const :deprecated_on, T.nilable(Date), default: nil
    const :webhook_description, T.nilable(String), default: nil
    const :schema, SchemaRegistry::Schema
    const :return_many, T::Boolean, default: false

    sig { returns(Symbol) }
    def schema_identifier
      @schema_identifier ||=
        T.let(:"#{id.to_s.underscore}_dto", T.nilable(Symbol))
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

    sig { returns(T.class_of(T::Struct)) }
    def dto
      dto_klass = dto_raw.safe_constantize

      if dto_klass.nil?
        raise DtoClassNotFound, "DTO class #{dto} for verb #{id} not found"
      end

      dto_klass
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def dump
      {}.tap do |result|
        result["id"] = id
        result["dto"] = dto.to_s
        result["schema"] = schema.dump
        result["return_many"] = return_many
      end
    end

    sig { params(spec: T.untyped).returns(Verb) }
    def self.load(spec)
      id = spec["id"]&.to_sym
      raise ArgumentError, "Missing verb ID: #{id}" if id.nil?

      dto = spec["dto"]
      raise ArgumentError, "DTO for verb #{id} not found" if dto.nil?

      new(
        id: id,
        dto_raw: dto,
        schema: SchemaRegistry::Schema.load(spec["schema"]),
        summary: spec["summary"],
        return_many: spec["return_many"],
        description: spec["description"],
        webhook_description: spec["webhook_description"]
      )
    end
  end
end
