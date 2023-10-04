# typed: strict

module ResourceRegistry
  module Capabilities
    # Represents configuration for a specific resource capability
    module CapabilityConfig
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Object }
      interface!

      sig { abstract.returns(Symbol) }
      def key
      end

      sig { abstract.returns(T::Hash[String, T.untyped]) }
      def serialize
      end
    end
  end
end
