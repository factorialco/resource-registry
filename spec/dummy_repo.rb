# typed: false

require_relative '../lib/public/repositories/base'
require_relative '../lib/public/repositories/read_output_context'

class DummyEntity < T::Struct
  const :id, Integer
end

class DummyRepo
  include ResourceRegistry::Repositories::Base

  Entity = type_member { { upper: DummyEntity } }

  sig do
    params(dto: T::Struct, context: ::Repositories::ReadOutputContext)
      .returns(::Repositories::ReadResult[Entity])
  end
  def read(dto:, context: ::Repositories::ReadOutputContext.new)
    entities = (1..10).map { |i| DummyEntity.new(id: i) }
    Repositories::InMemoryReadResult.new(
      context: Repositories::ReadOutputContext.new,
      list: entities
    )
  end
end
