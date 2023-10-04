# typed: strict

module ResourceRegistry
  module Oas
    class SchemaMapper
      extend T::Sig

      sig { params(resource: ResourceRegistry::Resource).void }
      def initialize(resource)
        @resource = resource
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def call
        content = raw_json_content
        base_schema = { 'required' => [], 'example' => [], 'properties' => {} }

        content['properties'].each { |key, value| compute_schema_object(base_schema, key, value) }
        purgue!(base_schema)

        { schema_key => base_schema }
      end

      private

      sig do
        params(
          content: T::Hash[String, T.untyped],
          key: String,
          value: T::Hash[String, T.untyped]
        ).void
      end
      def compute_schema_object(content, key, value)
        property = property_metadata(key)
        oas_type = type(value)

        content['properties'][key] = { 'deprecated' => property&.deprecated?, 'type' => oas_type }
        content['example'] << { key => property.example } if property&.example
        content['required'] << key if required_field?(value)
      end

      sig { returns(ResourceRegistry::Resource) }
      attr_reader :resource

      sig { params(content: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      def purgue!(content)
        content.reject! { |key| key == 'required' } if content['required'].count.zero?
        content.reject! { |key| key == 'example' } if content['example'].count.zero?

        content
      end

      sig { returns(SchemaRegistry::Schema) }
      def schema
        resource.schema
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def raw_json_content
        schema.raw_json_schema.values.first
      end

      sig { returns(String) }
      def schema_key
        schema.raw_json_schema.keys.first || ''
      end

      sig { params(hash: T::Hash[String, T.untyped]).returns(String) }
      def type(hash)
        value = hash['type']

        value.is_a?(Array) ? value.last : value
      end

      sig { params(hash: T::Hash[String, T.untyped]).returns(T::Boolean) }
      def required_field?(hash)
        value = T.let(hash['type'], T.nilable(T.any(T::Array[String], String)))

        !value.is_a?(Array)
      end

      sig { params(name: String).returns(T.nilable(SchemaRegistry::Property)) }
      def property_metadata(name)
        resource.schema.find_property(name)
      end
    end
  end
end
