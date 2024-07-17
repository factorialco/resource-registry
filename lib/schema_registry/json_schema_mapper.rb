# typed: strict

module SchemaRegistry
  class JsonSchemaMapper
    extend T::Sig

    class UnrecognizedJsonSchemaTypeError < StandardError
    end

    DATE_FIELDS = T.let(%w[date-time date].freeze, T::Array[String])

    # TODO: Proper type json-schema
    sig { params(namespace: String, definition: T.untyped).void }
    def initialize(namespace:, definition:)
      @namespace = namespace
      @definition = definition
    end

    sig { returns(Schema) }
    def call
      key = definition.keys.first

      properties = handle_properties(definition[key]['properties'], definition[key]['required'])

      Schema.new(
        name: key,
        namespace: namespace,
        properties: properties || [],
        raw_json_schema: definition,
        additional_filter_fields: handle_fields(definition[key]['additional_filter_fields'])
      )
    end

    private

    sig { returns(T.untyped) }
    attr_reader :definition

    sig { returns(String) }
    attr_reader :namespace

    sig do
      params(items: T.nilable(T::Hash[T.untyped, T.untyped])).returns(
        T::Array[SchemaRegistry::Property]
      )
    end
    def handle_items(items)
      return [] if items.nil?

      types = handle_types(items['type'], items['format'])

      [
        SchemaRegistry::Property.new(
          name: '',
          types: types,
          type_name: items['typedef'].to_s,
          items: handle_items(items['items']),
          enum_values: items.dig('items', 'enum') || items['enum'],
          default: items['default'],
          properties: handle_properties(items['properties'], items['required']) || [],
          required: types.exclude?(SchemaRegistry::PropertyType::Null)
        )
      ]
    end

    sig do
      params(input: T.nilable(T::Array[T::Hash[String, T.untyped]])).returns(T::Array[FilterField])
    end
    def handle_fields(input)
      return [] if input.nil?

      input.map do |obj|
        FilterField.new(
          name: obj['name'],
          resolver: handle_resolver(obj['resolver'] || obj['field']),
          type: type_to_sorbet(obj['type'], nil),
          in_memory: obj['in_memory'] == true
        )
      end
    end

    sig do
      params(
        properties: T.nilable(T::Hash[T.untyped, T.untyped]),
        required: T.nilable(T::Array[String])
      ).returns(T.nilable(T::Array[SchemaRegistry::Property]))
    end
    def handle_properties(properties, required)
      properties&.map do |key, value|
        enum_values =
          (value.dig('items', 'enum') || value['enum'] || []).map do |v|
            next v if v.is_a?(String)

            v.serialize
          end

        default =
          if enum_values.any? && value['default'].kind_of?(Array)
            # Handle arrays
            value['default']&.map do |v|
              next v if v.is_a?(String)

              v.serialize
            end
          else
            value['default']
          end

        SchemaRegistry::Property.new(
          name: key,
          types: handle_types(value['type'], value['format']),
          type_name: value['typedef'].to_s,
          items: handle_items(value['items']),
          example: value['example'],
          description: value['description'],
          enum_values: enum_values,
          default: default,
          resolver: handle_resolver(value['resolver']),
          resolvable: !value['resolvable'].nil? && value['resolvable'],
          properties: handle_properties(value['properties'], value['required']) || [],
          required: required ? required.include?(key) : false,
          serialization_groups: handle_serialization_groups(value['serialization_groups'])
        )
      end
    end

    sig do
      params(prop_type: T.any(String, T::Array[String]), format: T.nilable(String)).returns(
        T::Array[PropertyType]
      )
    end
    def handle_types(prop_type, format)
      Array(prop_type).map { |type| type_to_sorbet(type, format) }
    end

    sig { params(prop_type: T.any(String, T::Array[String])).returns(T::Boolean) }
    def nilable?(prop_type)
      return false unless prop_type.is_a?(Array)

      prop_type.include?('null')
    end

    sig do
      params(resolver: T.any(NilClass, String, T::Hash[Symbol, String])).returns(
        T.nilable(T::Hash[Symbol, String])
      )
    end
    def handle_resolver(resolver)
      if resolver.is_a?(String)
        { all: resolver }
      elsif resolver.present?
        resolver.symbolize_keys
      end
    end

    sig { params(serialization_groups: T.any(NilClass, T::Array[String])).returns(T::Set[Symbol]) }
    def handle_serialization_groups(serialization_groups)
      return Set[] if serialization_groups.blank?

      serialization_groups.compact.to_set(&:to_sym)
    end

    sig do
      params(json_schema_type: T.nilable(String), format: T.nilable(String)).returns(PropertyType)
    end
    def type_to_sorbet(json_schema_type, format)
      case json_schema_type
      when 'string'
        string_format_to_sorbet(format)
      when 'number'
        PropertyType::Number
      when 'integer'
        if format == 'big'
          PropertyType::BigInteger
        else
          PropertyType::Integer
        end
      when 'boolean'
        PropertyType::Boolean
      when 'null'
        PropertyType::Null
      when 'array'
        PropertyType::Array
      when 'object'
        PropertyType::Object
      else
        raise UnrecognizedJsonSchemaTypeError, "unrecognized type #{json_schema_type}"
      end
    end

    sig { params(format: T.nilable(String)).returns(PropertyType) }
    def string_format_to_sorbet(format)
      case format
      when 'date-time'
        PropertyType::DateTime
      when 'time'
        PropertyType::Time
      when 'date'
        PropertyType::Date
      when 'duration'
        PropertyType::Duration
      when 'email'
        PropertyType::Email
      when 'uri'
        PropertyType::Uri
      when 'regex'
        PropertyType::Regex
      when 'binary'
        PropertyType::File
      else
        PropertyType::String
      end
    end
  end
end
