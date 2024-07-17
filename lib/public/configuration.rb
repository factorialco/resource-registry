# frozen_string_literal: true
# typed: true

require_relative 'relationship_types/has_many'
require_relative 'relationship_types/has_many_through'
require_relative 'relationship_types/has_one'
require_relative 'relationship_types/belongs_to'

module ResourceRegistry
  class Configuration
    extend T::Sig

    DEFAULT_RELATIONSHIP_TYPES = {
      'has_many_through' => RelationshipTypes::HasManyThrough,
      'has_many' => RelationshipTypes::HasMany,
      'has_one' => RelationshipTypes::HasOne,
      'belongs_to' => RelationshipTypes::BelongsTo
    }.freeze

    sig { void }
    def initialize
      @relationship_types = DEFAULT_RELATIONSHIP_TYPES.dup
      @capabilities = {}
    end

    sig { params(type: String, klass: T.class_of(RelationshipType)).void }
    def register_relationship_type(type, klass)
      @relationship_types[type] = klass
    end

    sig { params(capability: Symbol, klass: T.class_of(Capabilities::CapabilityConfig)).void }
    def register_capability(capability, klass)
      @capabilities[capability] = klass
    end

    sig { returns(T::Hash[String, T::Class[RelationshipType]]) }
    attr_reader :relationship_types

    sig do
      returns(
        T::Hash[Symbol, T.all(T::Class[Capabilities::CapabilityConfig], T.class_of(T::Struct))]
      )
    end
    attr_reader :capabilities
  end
end
