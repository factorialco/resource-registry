# frozen_string_literal: true
# typed: false

require_relative "../../runtime_generic"
require_relative "../serializer"

module ResourceRegistry
  module Repositories
    module Base
      extend T::Sig
      extend T::Helpers
      extend T::Generic
      # CAUTION This is not supported by sorbet, consider using T::Generic
      # instead if yo don't need to preserve generic runtime information
      extend RuntimeGeneric

      include Kernel

      abstract!

      Entity = type_member { { upper: T::Struct } }

      sig { returns(T.untyped) }
      def self.entity
        T.unsafe(const_get(:Entity)).inner_type[:fixed]
      end

      sig do
        overridable
          .params(dto: T.untyped, context: T.untyped)
          .returns(T.untyped)
      end
      def read(dto:, context:)
        raise_error(__method__)
      end

      sig do
        overridable
          .params(entity: Entity, tags: T::Set[T.untyped])
          .returns(T::Hash[Symbol, T.untyped])
      end
      def serialize(entity:, tags: [])
        serializer.serialize(entity: entity, tags: tags)
      end

      sig(:final) { returns(String) }
      def self.namespace
        namespace = to_s.split("::Repositories").first
        return T.must(namespace).sub("::", "") if namespace != to_s

        T.must(to_s.split("::").first)
      end

      sig(:final) { returns(String) }
      def self.resource_name
        T.must(to_s.split("::").last)
      end

      private

      sig { returns(ResourceRegistry::Serializer) }
      def serializer
        @serializer ||=
          T.let(
            ResourceRegistry::Serializer.new(
              resource: T.must(self.class.resource)
            ),
            T.nilable(ResourceRegistry::Serializer)
          )
      end

      sig { params(method: T.nilable(Symbol)).returns(T.noreturn) }
      def raise_error(method)
        raise NotImplementedError,
              "#{method} must be implemented in #{self.class} repository"
      end
    end
  end
end
