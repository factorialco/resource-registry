# typed: strict

module ResourceRegistry
  module Capabilities
    class PowerBi < T::Struct
      extend T::Sig
      include CapabilityConfig

      sig { override.returns(Symbol) }
      def key
        :power_bi
      end
    end
  end
end
