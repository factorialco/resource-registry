# frozen_string_literal: true
# typed: true

require "sorbet-runtime"

require "public/configuration"
require "public/resource"
require "public/versions"
require "public/versions/version"
require "public/entity_finder"
require "schema_registry/json_schema_mapper"
require "schema_registry/maybe"
require "schema_registry/generate_from_struct"
require "runtime_generic"
require "public/resource_struct_builder"
require "public/registry"

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
