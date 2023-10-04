# typed: strict

module ResourceRegistry
  module TraitMapper
    class Base
      extend T::Sig
      extend T::Generic

      class TraitMapperException < StandardError
      end

      abstract!

      EventPayload = type_member { { upper: T::Struct } }
      Entity = type_member { { upper: T::Struct } }

      sig(:final) do
        params(event_class: T::Class[EventPayload], entity: Entity).returns(T.nilable(EventPayload))
      end
      def call(event_class:, entity:)
        map(event_class: event_class, entity: entity)
        # We are catching all exceptions here because an error in a mapper would make the mutation
        # that triggered the mapper to fail. We want to avoid that as generating the trait event is
        # not a critical operation, and we can run a reconciliation task at some point to fix consistency.
      rescue StandardError => e
        # We are reporting the exception twice to be able to track any TraitMapperExceptions easily
        FactorialException.capture(e)
        FactorialException.capture(TraitMapperException.new(e))
      end

      sig do
        overridable
          .params(event_class: T::Class[EventPayload], entity: Entity)
          .returns(T.nilable(EventPayload))
      end
      def map(event_class:, entity:)
        raise NotImplementedError, "map must be implemented in #{self.class} mapper"
      end
    end
  end
end
