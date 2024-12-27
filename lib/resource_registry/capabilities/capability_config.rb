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
        extend T::Generic
        extend T::Helpers
        abstract!

        has_attached_class!

        # The key of the capability, this key will be used to take it from yaml configuration
        sig { abstract.returns(Symbol) }
        def key
        end

        sig { params(resource: Resource).returns(T::Boolean) }
        def resource_capability?(resource:)
          resource.capabilities.key?(key)
        end

        sig do
          params(resource: Resource).returns(
            T.nilable(T.attached_class)
          )
        end
        def resource_capability(resource:)
          return unless resource_capability?(resource:)

          T.cast(resource.capabilities[key], T.attached_class)
        end

        sig do
          params(resource: Resource).returns(T.attached_class)
        end
        def resource_capability!(resource:)
          T.must(resource_capability(resource: ))
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
