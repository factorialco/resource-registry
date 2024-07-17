# frozen_string_literal: true
# typed: strict

require_relative 'capability_config'

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
