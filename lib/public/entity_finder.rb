# typed: strict

module ResourceRegistry
  class EntityFinder
    extend T::Sig

    sig do
      params(repository: T.class_of(Repositories::Base)).returns(T.nilable(T.class_of(T::Struct)))
    end
    def self.call(repository:)
      entity = repository.entity

      return nil if entity.is_a?(T::Types::Untyped)

      entity
    end
  end
end
