# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

require 'public/initializer'
require 'public/configuration'
require 'public/resource'
require 'public/versions'
require 'public/versions/version'
require 'schema_registry/json_schema_mapper'
require 'schema_registry/maybe'

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
