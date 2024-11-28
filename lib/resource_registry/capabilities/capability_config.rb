# frozen_string_literal: true
# typed: strict

module ResourceRegistry
  module Capabilities
    # Represents configuration for a specific resource capability
    module CapabilityConfig
      extend T::Helpers
      extend T::Sig
      include Kernel

      interface!

      # Class methods interface for capability configuration
      module ClassMethods
        extend T::Sig
        extend T::Helpers
        abstract!

        # The key of the capability, this key will be used to take it from yaml configuration
        sig { abstract.returns(Symbol) }
        def key
        end
      end

      requires_ancestor { Object }

      mixes_in_class_methods(ClassMethods)

      sig { abstract.returns(T::Hash[String, T.untyped]) }
      def serialize
      end
    end
  end
end
