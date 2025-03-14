# typed: strict

require "forge/synthesizer"
require "forge/concept"
require "forge/artifact"

class Forge
  extend T::Sig

  sig { void }
  def initialize
    @synthesizers = T.let(Set.new, T::Set[Synthesizer])
  end

  sig { params(synthesizer: Synthesizer).void }
  def register_synthesizer(synthesizer)
    synthesizers << synthesizer
  end

  sig { params(concept: Concept).void }
  def forge(concept)
    pending_deletions = Set.new

    # Find things that need to be deleted
    synthesizers.each do |synthesizer|
      path = synthesizer.path(concept)

      # File does not exist
      next unless File.exist?(path)

      # File exists but the synthesizer no longer works on it, delete it
      next pending_deletions << path unless synthesizer.synthesizes?(concept)

      # File exists, the synthesizer has pending work
      pending_deletions << path
    end

    # Delete generated files that are no longer needed
    T.unsafe(File).delete(*pending_deletions)

    need_rebuild = synthesizers_for(concept)

    # Find all synthesizers for the concept and synthesize
    need_rebuild.each do |synthesizer|
      artifact = synthesizer.synthesize(concept)
      artifact.write!
    end
  end

  private

  sig { params(concept: Concept).returns(T::Set[Synthesizer]) }
  def synthesizers_for(concept)
    Set.new(
      synthesizers.filter { |synthesizer| synthesizer.synthesizes?(concept) }
    )
  end

  sig { returns(T::Set[Synthesizer]) }
  attr_reader :synthesizers
end
