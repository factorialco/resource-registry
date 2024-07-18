# typed: true

class DummyEntity < T::Struct
  const :id, Integer
end

class DummyRepo < Repositories::Base
  Entity = type_member { { upper: DummyEntity } }

  sig do
    override
      .params(dto: T::Struct, context: ::Repositories::ReadOutputContext)
      .returns(::Repositories::ReadResult[Entity])
  end
  def read(dto:, context: ::Repositories::ReadOutputContext.new)
    entities = (1..10).map { |i| DummyEntity.new(id: i) }
    Repositories::InMemoryReadResult.new(
      context: Repositories::ReadOutputContext.new,
      list: entities
    )
  end

  sig { override.params(entity: DummyEntity).returns(T::Hash[Symbol, T.untyped]) }
  def serialize(entity:)
    entity.serialize.symbolize_keys
  end
end
