# frozen_string_literal: true
# typed: strict

require_relative '../../runtime_generic'

module ResourceRegistry
  module Repositories
    class Base
      extend T::Sig
      # CAUTION This is not supported by sorbet, consider using T::Generic
      # instead if yo don't need to preserve generic runtime information
      extend RuntimeGeneric

      abstract!

      sig { returns(T.nilable(ResourceRegistry::Resource)) }
      def self.resource
        Rails.configuration.resource_registry.fetch_for_repository(self)
      end

      Entity = type_member { { upper: T::Struct } }

      sig { returns(T.untyped) }
      def self.entity
        T.unsafe(const_get(:Entity)).inner_type[:fixed]
      end

      sig do
        overridable
          .params(dto: T.untyped, context: Repositories::ReadOutputContext)
          .returns(Repositories::ReadResult[Entity])
      end
      def read(dto:, context: ::Repositories::ReadOutputContext.new)
        raise_error(__method__)
      end

      sig { overridable.params(dto: T.untyped).returns(Outcome[Entity]) }
      def create(dto:)
        raise_error(__method__)
      end

      sig { overridable.params(dto: T.untyped).returns(Outcome[Entity]) }
      def update(dto:)
        raise_error(__method__)
      end

      sig { overridable.params(dto: T.untyped).returns(Outcome[Entity]) }
      def delete(dto:)
        raise_error(__method__)
      end

      sig(:final) { params(dto: T.untyped).returns(Outcome[Entity]) }
      def find(dto:)
        read(dto: dto).entities.map do |array|
          entity = array.first
          return Outcome.missing_resource if entity.nil?

          entity
        end
      end

      # sig { overridable.params(entity: Entity, tags: T::Set[SerializationTags]).returns(T::Hash[Symbol, T.untyped]) }
      # def serialize(entity:, tags: [])
      sig { overridable.params(entity: Entity).returns(T::Hash[Symbol, T.untyped]) }
      def serialize(entity:)
        serializer.serialize(entity: entity, tags: Set[])
      end

      sig(:final) { returns(String) }
      def self.namespace
        namespace = to_s.split('::Repositories').first
        return T.must(namespace).sub('::', '') if namespace != to_s

        T.must(to_s.split('::').first)
      end

      sig(:final) { returns(String) }
      def self.resource_name
        T.must(to_s.split('::').last)
      end

      private

      sig { returns(ResourceRegistry::Serializer) }
      def serializer
        @serializer ||=
          T.let(
            ResourceRegistry::Serializer.new(resource: T.must(self.class.resource)),
            T.nilable(ResourceRegistry::Serializer)
          )
      end

      # FIXME: should be abstract instead of overridable, but to please
      # the Gods of Incremental Migration
      sig do
        overridable
          .params(dto: T::Struct)
          .returns(T.nilable(T.any(Permissions::Target, T::Array[Permissions::Target])))
      end
      def target_from(dto); end

      sig { params(method: T.nilable(Symbol)).returns(T.noreturn) }
      def raise_error(method)
        raise NotImplementedError, "#{method} must be implemented in #{self.class} repository"
      end
    end
  end
end
