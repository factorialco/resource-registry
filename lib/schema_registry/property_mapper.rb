# typed: strict

module SchemaRegistry
  class PropertyMapper
    extend T::Sig

    # TODO: Proper type json-schema
    sig { params(schema: Schema).void }
    def initialize(schema:)
      @schema = schema
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def call
      schema
        .properties
        .each_with_object({}) do |property, memo|
          json_type = sorbet_to_json_schema(property)
          json_type = ["null", json_type] if property.nilable?

          memo[property.name] = { "type" => json_type }
        end
    end

    private

    sig { returns(Schema) }
    attr_reader :schema

    sig { params(property: Property).returns(T.untyped) }
    def sorbet_to_json_schema(property)
      properties = property.types.map(&:serialize)

      return "integer" if properties.include?("integer")
      return "boolean" if properties.include?("boolean")
      return "number" if properties.include?("number")

      "string"
    end
  end
end
