# typed: strict
# frozen_string_literal: true

require_relative "../repository"

class ReadDto < T::Struct
  const :id, String
end

class Dog < T::Struct
  const :id, String
end

class Dogs < Repository
  extend T::Sig

  Entity = type_member { { fixed: Dog } }

  # FIXME: Review `context`
  sig do
    override.params(dto: ReadDto, context: T.untyped).returns(T::Array[Dog])
  end
  def read(dto:, context:)
    []
  end
end
