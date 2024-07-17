# typed: strict

module ResourceRegistry
  module RelationshipTypeFactory
    extend T::Sig

    # FIXME: Allow a more dynamic and future proof way to register relationship types
    sig { params(spec: T.untyped).returns(RelationshipType) }
    def self.from_spec(spec)
      type = ResourceRegistry.configuration.relationship_types[spec['type']]

      raise "Unknown relationship type #{spec}" unless type

      type.new(spec)
    end
  end
end
