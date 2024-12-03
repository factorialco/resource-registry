# frozen_string_literal: true
# typed: true

require "sorbet-runtime"
require "active_support/all"

require "resource_registry/configuration"
require "resource_registry/resource"
require "resource_registry/versions"
require "resource_registry/versions/version"
require "resource_registry/entity_finder"
require "resource_registry/registry"
require "resource_registry/serializer"
require "resource_registry/repositories/base"
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
