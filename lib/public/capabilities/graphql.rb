# frozen_string_literal: true
# typed: strict

require_relative 'capability_config'

module ResourceRegistry
  module Capabilities
    class Graphql < T::Struct
      extend T::Sig
      include CapabilityConfig

      const :included_in_root_query, T::Boolean, default: true

      sig { override.returns(Symbol) }
      def key
        :graphql
      end
    end
  end
end
