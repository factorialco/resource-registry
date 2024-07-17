# typed: strict

require_relative 'capability_config'

module ResourceRegistry
  module Capabilities
    class Rest < T::Struct
      extend T::Sig
      include CapabilityConfig

      const :is_public, T::Boolean, default: false

      sig { override.returns(Symbol) }
      def key
        :rest
      end
    end
  end
end
