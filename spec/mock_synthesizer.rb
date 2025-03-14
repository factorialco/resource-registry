# typed: strict
# frozen_string_literal: true

require_relative "../lib/forge/synthesizer"

class MockSynthesizer
  extend T::Sig
  include Forge::Synthesizer

  NAME = "Dummy Synthesizer"
  PATH = "tmp/dummy.txt"

  sig { void }
  def initialize
    @synthesizes = T.let(true, T::Boolean)
    @content = T.let("This is a dummy synthesizer", String)
  end

  sig { override.returns(String) }
  def name
    NAME
  end

  sig { returns(T::Boolean) }
  attr_accessor :synthesizes

  sig { returns(String) }
  attr_accessor :content

  sig { override.params(concept: Forge::Concept).returns(T::Boolean) }
  def synthesizes?(concept)
    synthesizes
  end

  sig { override.params(concept: Forge::Concept).returns(Forge::Artifact) }
  def synthesize(concept)
    Forge::Artifact.new(content: content, path: PATH)
  end

  sig { override.params(concept: Forge::Concept).returns(String) }
  def path(concept)
    PATH
  end
end
