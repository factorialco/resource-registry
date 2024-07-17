# frozen_string_literal: true
# typed: strict

require_relative 'capability_config'

module ResourceRegistry
  module Capabilities
    class AutogeneratePermissions < T::Struct
      extend T::Sig
      include CapabilityConfig

      sig { override.returns(Symbol) }
      def key
        :autogenerate_permissions
      end
    end
  end
end
