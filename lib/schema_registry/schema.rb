# frozen_string_literal: true
# typed: strict

require_relative 'property'
require_relative 'filter_field'
require_relative 'property_mapper'

module SchemaRegistry
  class Schema < T::Struct
    extend T::Sig

    const :name, String
    const :namespace, String
    const :properties, T::Array[Property]
    const :raw_json_schema, T::Hash[String, T.untyped], default: {}
    const :additional_filter_fields, T::Array[FilterField], default: []

    sig { returns(String) }
    def schema_module_name
      name
    end

    sig { returns(String) }
    def slug
      name.underscore
    end

    sig { returns(Symbol) }
    def identifier
      :"#{namespace.underscore}.#{slug}"
    end

    sig { returns(String) }
    def namespace_with_slug
      "#{namespace.underscore}_#{slug}"
    end

    sig { params(name: String).returns(T.nilable(Property)) }
    def find_property(name)
      properties.find { |property| property.name == name }
    end

    sig { params(name: String).returns(T.nilable(FilterField)) }
    def find_additional_filter_field(name)
      additional_filter_fields.find { |field| field.name == name }
    end

    sig { params(name: String).returns(T::Boolean) }
    def has_property?(name)
      find_property(name).present?
    end

    sig { returns(String) }
    def namespace_with_slug
      "#{namespace.underscore}_#{slug}"
    end

    sig { params(name: String).returns(T.nilable(T::Hash[Symbol, String])) }
    def get_resolver(name)
      property = find_property(name)
      raise "No resolvable schema property of name #{name} exists" unless property&.resolvable

      property.resolver
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def raw_json_schema
      return @raw_json_schema if @raw_json_schema.present?

      properties = PropertyMapper.new(schema: self).call

      { name => { 'type' => 'object', 'properties' => properties } }
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def dump
      {}.tap do |result|
        result['namespace'] = namespace
        result['raw_json_schema'] = raw_json_schema
      end
    end

    sig { params(spec: T.untyped).returns(Schema) }
    def self.load(spec)
      JsonSchemaMapper.new(namespace: spec['namespace'], definition: spec['raw_json_schema']).call
    end
  end
end
