# typed: strict

module ResourceRegistry
  module Oas
    class PayloadMapper
      extend T::Sig

      sig do
        params(
          verb: ResourceRegistry::Verb,
          resource: ResourceRegistry::Resource,
          id_param: T::Boolean,
          creation: T::Boolean
        ).void
      end
      def initialize(verb, resource, id_param, creation)
        @verb = verb
        @resource = resource
        @id_param = id_param
        @creation = creation
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def call
        {
          tags: tags,
          security: security,
          description: description,
          deprecated: verb.deprecated?,
          summary: summary,
          parameters: parameters,
          responses: responses
        }.merge body
      end

      private

      sig { returns(ResourceRegistry::Verb) }
      attr_reader :verb

      sig { returns(ResourceRegistry::Resource) }
      attr_reader :resource

      sig { returns(T::Boolean) }
      attr_reader :id_param

      sig { returns(T::Boolean) }
      attr_reader :creation

      sig { returns(T::Array[T.untyped]) }
      def parameters
        ResourceRegistry::Oas::ParameterMapper.new(verb, resource, id_param).call
      end

      sig { returns(String) }
      def summary
        verb.summary ||
          "#{verb.id.to_s.pluralize.capitalize.humanize} a/an #{resource.name.to_s.humanize}"
      end

      sig { returns(String) }
      def description
        verb.description ||
          "#{verb.id.to_s.pluralize.capitalize.humanize} a/an #{resource.name.to_s.humanize}"
      end

      sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
      def security
        [{ oauth2: [] }, { apikey: [] }]
      end

      sig { returns(T::Array[String]) }
      def tags
        ["#{resource.namespace.to_s.camelize} > #{resource.name.to_s.camelize}"]
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def responses
        resource_schema = resource.schema

        if id_param
          object_response(resource_schema.name, creation: creation)
        else
          collection_response(resource_schema.name)
        end
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def body
        schema = verb.schema
        body_schema = schema.raw_json_schema.values.first

        return {} if verb.get? || verb.destroy?

        { requestBody: request_body(body: body_schema) }
      end

      sig { params(body: T::Hash[T.untyped, T.untyped]).returns(T::Hash[T.untyped, T.untyped]) }
      def request_body(body:)
        oas_output = { 'required' => [], 'properties' => {} }

        oas_output['type'] = body['type']

        body['properties'].each do |k, v|
          type = v['type']

          oas_output['properties'][k] = if type.is_a? Array
            { 'type' => type.last }
          else
            { 'type' => type }
          end

          oas_output['required'] << k unless type.is_a?(Array) && type.include?('null')
        end

        oas_output.reject! { |k| k == 'required' } if oas_output['required'].count.zero?

        { content: { 'application/json': { schema: oas_output } } }
      end

      sig { params(schema_id: String, creation: T::Boolean).returns(T::Hash[String, T.untyped]) }
      def object_response(schema_id, creation: false)
        resp = {}

        code = creation ? '201' : '200'
        desc = creation ? 'CREATED' : 'OK'

        resp[code] = {
          description: desc,
          content: {
            'application/json': {
              schema: {
                '$ref': "#/components/schemas/#{schema_id}"
              }
            }
          }
        }
        resp
      end

      sig { params(schema_id: String).returns(T::Hash[String, T.untyped]) }
      def collection_response(schema_id)
        {
          '200': {
            description: 'OK',
            content: {
              'application/json': {
                schema: {
                  type: 'array',
                  items: {
                    '$ref': "#/components/schemas/#{schema_id}"
                  }
                }
              }
            }
          }
        }
      end
    end
  end
end
