# typed: strict

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
