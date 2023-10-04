# typed: strict
# frozen_string_literal: true

# Defines a fixed schema to translate resource registry resource names, field
# names and enum values in an extensible and future-proof way.
#
# This is an example schema for the `my_domain` domain:
#
# ```yaml
# my_domain_id:
#   resources:
#     my_resource_id:
#       name: My resource
#       fields:
#         a_field_id:
#           name: A field
#         an_enum_field_id:
#           name: Some other field
#           enum:
#             active:
#               name: Active
#             inactive:
#               name: Inactive
# ```
#
# Resource registry users can then add translations to their domains using this
# same syntax and this class will do the automatic bounding of such translations
# and their respective resources.
module ResourceRegistry
  class I18nKeysForResource
    extend T::Sig

    INFIX_RESOURCES = 'resources'
    INFIX_FIELDS = 'fields'
    INFIX_ENUM = 'enum'
    SUFFIX_NAME = 'name'

    sig { params(resource: Resource).void }
    def initialize(resource)
      @resource = resource
    end

    sig { returns(String) }
    def resource_name_key
      suffix_name(resource_key)
    end

    sig { params(field: Symbol).returns(String) }
    def field_name_key(field)
      suffix_name(field_key(field))
    end

    sig { params(field: Symbol, value: Symbol).returns(String) }
    def enum_value_name_key(field, value)
      suffix_name(enum_value_key(field, value))
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def hash
      {
        domain_segment => {
          INFIX_RESOURCES => {
            resource_segment => {
              SUFFIX_NAME => nil,
              INFIX_FIELDS => {
              }
            }
          }
        }
      }
    end

    private

    sig { params(key: String).returns(String) }
    def suffix_name(key)
      "#{key}.#{SUFFIX_NAME}"
    end

    sig { returns(String) }
    def domain_segment
      resource.namespace.underscore
    end

    sig { returns(String) }
    def resource_segment
      resource.slug
    end

    sig { returns(String) }
    def resource_key
      "#{domain_segment}.#{INFIX_RESOURCES}.#{resource_segment}"
    end

    sig { params(field: Symbol).returns(String) }
    def field_key(field)
      "#{resource_key}.#{INFIX_FIELDS}.#{field}"
    end

    sig { params(field: Symbol, value: Symbol).returns(String) }
    def enum_value_key(field, value)
      fixed_value = value.empty? ? :none : value
      "#{field_key(field)}.#{INFIX_ENUM}.#{fixed_value}"
    end

    sig { returns(Resource) }
    attr_reader :resource
  end
end
