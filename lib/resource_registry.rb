require 'sorbet-runtime'

require 'public/initializer'

# frozen_string_literal: true
# typed: true

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
