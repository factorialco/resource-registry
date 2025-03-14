# typed: strict

require_relative "concept"
require_relative "artifact"

class Forge
  # A `Synthesizer` can be used to synthesize source code from a given resource.
  #
  # This enables defining capabilities that create static source files instead of
  # metaprogramming things at runtime. Synthesizers should be able to be applied
  # over a single resource, schema or verb.
  module Synthesizer
    extend T::Sig
    extend T::Helpers
    interface!

    # Returns the name of the synthesizer.
    sig { abstract.returns(String) }
    def name
    end

    # Returns true if the synthesizer can synthesize an artifact for the given
    # concept.
    # This should implement any checks to determine if the synthesizer can
    # synthesize the given concept, for example, checking if the concept has
    # appropriate capabilities.
    sig { abstract.params(concept: Forge::Concept).returns(T::Boolean) }
    def synthesizes?(concept)
    end

    # Synthesizes an artifact for the given concept.
    sig { abstract.params(concept: Forge::Concept).returns(Forge::Artifact) }
    def synthesize(concept)
    end

    # Returns the path to create the output file for the given concept
    sig { abstract.params(concept: Forge::Concept).returns(String) }
    def path(concept)
    end
  end
end
