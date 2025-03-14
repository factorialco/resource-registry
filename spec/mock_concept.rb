# typed: strict
# frozen_string_literal: true

class MockConcept
  extend T::Sig
  include Forge::Concept

  sig { void }
  def initialize
    @dump = T.let({}, T::Hash[Symbol, T.untyped])
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_accessor :dump

  sig { override.returns(Symbol) }
  def identifier
    :fake
  end
end
