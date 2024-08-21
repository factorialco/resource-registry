# typed: false
# frozen_string_literal: true

module ResourceRegistry
  class OpenapiSpecificationGenerator
    extend T::Sig

    OPENAPI_VERSION = T.let('3.0.0', String)
    FACTORIAL_VERSION = T.let('2.0.0', String)
    PRODUCTION_URL = T.let('https://api.factorialhr.com', String)
    DEMO_URL = T.let('https://api.demo.factorial.dev', String)

    sig { params(resources: T::Array[Resource]).void }
    def initialize(resources:)
      @resources = resources
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def call
      specification
    end

    private

    sig { returns(T::Array[Resource]) }
    attr_reader :resources

    sig { returns(T::Hash[String, T.untyped]) }
    def specification
      spec = {
        openapi: OPENAPI_VERSION,
        info: {
          title: 'Factorial API',
          description: '',
          version: FACTORIAL_VERSION
        },
        'x-readme': {
          'proxy-enabled': false
        },
        servers: [{ url: PRODUCTION_URL }, { url: DEMO_URL }],
        security: [{ oauth2: [] }],
        tags: resource_tags,
        paths: resource_paths,
        components: {
          securitySchemes: {
            oauth2: {
              type: 'oauth2',
              flows: {
                authorizationCode: {
                  authorizationUrl: '/oauth/authorize',
                  tokenUrl: '/oauth/token',
                  refreshUrl: '/oauth/token',
                  scopes: {
                    read: 'Required for all operations',
                    write: 'Required for write operations'
                  }
                }
              }
            },
            apikey: {
              type: 'apiKey',
              in: 'header',
              name: 'x-api-key'
            }
          },
          schemas: schemas
        }
      }

      JSON.parse(spec.to_json)
    end

    sig { params(resource: Resource).returns(String) }
    def tag_from_resource(resource)
      "#{resource.namespace.to_s.camelize} > #{resource.name.to_s.camelize}"
    end

    sig do
      params(res: Resource, verb: Verb, with_id_param: T::Boolean, creation: T::Boolean).returns(
        T::Hash[Symbol, T.untyped]
      )
    end
    def path_payload(res, verb, with_id_param: false, creation: false)
      ResourceRegistry::Oas::PayloadMapper.new(verb, res, with_id_param, creation).call
    end

    sig do
      params(with_id_params: T::Boolean, verb: Verb, res: Resource).returns(T::Array[T.untyped])
    end
    def parameters(with_id_params, verb, res)
      ResourceRegistry::Oas::ParameterMapper.new(verb, res, with_id_params).call
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def resource_paths
      resources.each_with_object({}) { |res, memo| setup_verbs(res, memo) }
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    sig do
      params(res: Resource, memo: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped])
    end
    def setup_verbs(res, memo)
      read_verb = res.verbs[:read]
      create_verb = res.verbs[:create]
      update_verb = res.verbs[:update]
      delete_verb = res.verbs[:delete]
      rest_base = "/api/v2/resources/#{res.namespace.underscore}"
      slug = res.slug.pluralize

      if read_verb
        col_url = "#{rest_base}/#{slug}"
        memo[col_url] = {}
        memo[col_url]['get'] = path_payload(res, read_verb)

        obj_url = "#{rest_base}/#{slug}/{id}"
        memo[obj_url] = {}
        memo[obj_url]['get'] = path_payload(res, read_verb, with_id_param: true)
      end

      if create_verb
        create_url = "#{rest_base}/#{slug}"
        memo[create_url] = {} unless memo[create_url]
        memo[create_url]['post'] = path_payload(res, create_verb, creation: true)
      end

      if update_verb
        update_url = "#{rest_base}/#{slug}/{id}"
        memo[update_url] = {} unless memo[update_url]
        memo[update_url]['put'] = path_payload(res, update_verb, with_id_param: true)
      end

      if delete_verb
        delete_url = "#{rest_base}/#{slug}/{id}"
        memo[delete_url] = {} unless memo[delete_url]
        memo[delete_url]['delete'] = path_payload(res, delete_verb, with_id_param: true)
      end

      res.rpc_verbs.each do |v|
        rpc_url = "#{rest_base}/#{slug}/#{v.id}"
        memo[rpc_url] = {}
        memo[rpc_url]['post'] = path_payload(res, v)
      end

      memo
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize

    sig { returns(T::Hash[String, T.untyped]) }
    def schemas
      resources.each_with_object({}) { |res, memo| memo.merge! Oas::SchemaMapper.new(res).call }
    end

    sig { returns(T::Array[{ name: String, description: String }]) }
    def resource_tags
      resources.map { |res| { name: tag_from_resource(res), description: res.description } }
    end
  end
end
