# typed: strict

module SchemaRegistry
  class Registry
    extend T::Sig

    SchemaNotFound = Class.new(StandardError)

    sig { void }
    def initialize
      @schemas = T.let({}, T::Hash[Symbol, Schema])
    end

    sig { params(schema: Schema).returns(SchemaRegistry::Registry) }
    def register(schema)
      @schemas[schema.identifier] = schema

      self
    end

    sig do
      params(identifier: Symbol).returns(T.nilable(SchemaRegistry::Schema))
    end
    def fetch!(identifier)
      unless @schemas[identifier]
        raise SchemaNotFound, "Schema for #{identifier} can not be found"
      end

      @schemas[identifier]
    end

    sig do
      params(identifier: Symbol).returns(T.nilable(SchemaRegistry::Schema))
    end
    def fetch(identifier)
      @schemas[identifier]
    end

    sig { returns(T::Hash[Symbol, SchemaRegistry::Schema]) }
    def fetch_all
      @schemas
    end

    sig { returns(SchemaRegistry::Registry) }
    def cleanup
      @schemas = {}

      self
    end
  end
end
