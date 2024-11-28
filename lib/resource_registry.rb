# frozen_string_literal: true
# typed: true

require "sorbet-runtime"

require "public/configuration"
require "public/resource"
require "public/versions"
require "public/versions/version"
require "public/entity_finder"
require "public/resource_struct_builder"
require "public/registry"
require "public/serializer"
require "public/repositories/base"
require "schema_registry/registry"
require "schema_registry/json_schema_mapper"
require "schema_registry/maybe"
require "runtime_generic"

# Entry point for ResourceRegistry
module ResourceRegistry
  class << self
    extend T::Sig

    sig { returns(Configuration) }
    def configuration
      @configuration ||= Configuration.new
    end

    sig { void }
    def configure
      yield(configuration)
    end
  end
end
