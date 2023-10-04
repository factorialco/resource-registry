# typed: strict

module ResourceRegistry
  module Oas
    class ParameterMapper
      extend T::Sig

      sig do
        params(
          verb: ResourceRegistry::Verb,
          resource: ResourceRegistry::Resource,
          id_param: T::Boolean
        ).void
      end
      def initialize(verb, resource, id_param)
        @verb = verb
        @resource = resource
        @id_param = id_param
      end

      sig { returns(T::Array[T::Hash[String, T.untyped]]) }
      def call
        return [] if verb.mutation? && !id_param?
        if id_param? && (verb.mutation? || verb.get?)
          return [build_param('id', nil, 'string', true, nil)]
        end

        parameters = []

        schema = raw_json_content

        schema['properties'].each do |key, value|
          oas_type = type(value)
          item_type = value['items']['type'] if oas_type == 'array'
          property = property_metadata(key)
          parameters << build_param(key, property, oas_type, required_field?(value), item_type)
        end

        parameters
      end

      private

      sig { returns(ResourceRegistry::Verb) }
      attr_reader :verb

      sig { returns(ResourceRegistry::Resource) }
      attr_reader :resource

      sig { returns(T::Boolean) }
      attr_reader :id_param

      sig do
        params(
          key: String,
          property: T.nilable(SchemaRegistry::Property),
          type: String,
          required: T::Boolean,
          item_type: T.nilable(String)
        ).returns(T::Hash[String, T.untyped])
      end
      def build_param(key, property, type, required, item_type)
        schema = { type: type }
        name = key

        if item_type
          schema[:items] = { type: item_type }
          name = "#{key}[]"
        end

        {
          name: name,
          description: property&.description || '',
          example: property&.example || '',
          deprecated: property&.deprecated? || false,
          required: required,
          in: (key == 'id' && id_param? ? 'path' : 'query'),
          schema: schema
        }
      end

      sig { returns(T::Boolean) }
      def id_param?
        id_param
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

      sig { returns(SchemaRegistry::Schema) }
      def schema
        verb.schema
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def raw_json_content
        schema.raw_json_schema.values.first
      end

      sig { params(name: String).returns(T.nilable(SchemaRegistry::Property)) }
      def property_metadata(name)
        schema.find_property name
      end
    end
  end
end
