# typed: false

require_relative '../lib/public/repositories/base'

class DummyEntity < T::Struct
  const :id, Integer
end

class DummyRepo
  extend T::Sig
  extend T::Helpers
  extend T::Generic

  include ResourceRegistry::Repositories::Base

  Entity = type_member { { upper: DummyEntity } }

  sig do
    params(dto: T::Struct, context: T.untyped)
      .returns(::Repositories::ReadResult[Entity])
  end
  def read(dto:, context: ::Repositories::ReadOutputContext.new)
    entities = (1..10).map { |i| DummyEntity.new(id: i) }
    Repositories::InMemoryReadResult.new(
      context: context.new,
      list: entities
    )
  end
end
