# typed: true

module ResourceRegistry
  class Serializer
    extend T::Sig

    # Maybe this should be a generic?
    sig { params(resource: Resource).void }
    def initialize(resource:)
      @resource = resource
    end

    sig { params(entity: T::Struct, tags: T::Set[Symbol]).returns(T::Hash[Symbol, T.untyped]) }
    def serialize(entity:, tags:)
      entity_methods = Set.new(entity.methods)

      resource_schema
        .properties
        .each_with_object({}) do |property, acc|
          # If property has serialization groups and they are not included in the tags this property is skipped
          next if property.serialization_groups.any? && (property.serialization_groups & tags).none?

          property_value =
            if entity_methods.include?(property.name.to_sym)
              entity.send(property.name)
            elsif property.resolvable && (property.resolver&.values&.size || 0) > 1
              # Review all this mess with resolvers
              property.resolver&.map { |_, value| entity.send(value) }&.join(' ')
            else
              next
            end

          acc[property.name.to_sym] = recursive_serialization(property_value)
        end
    end

    private

    sig { params(property_value: T.untyped).returns(T.untyped) }
    def recursive_serialization(property_value)
      return property_value.map { |pv| recursive_serialization(pv) } if property_value.is_a?(Array)

      property_value.respond_to?(:serialize, false) ? property_value.serialize : property_value
    end

    sig { returns(SchemaRegistry::Schema) }
    def resource_schema
      @resource.schema
    end
  end
end
