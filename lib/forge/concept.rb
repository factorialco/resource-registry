# typed: strict

class Forge
  # The `Concept` interface represents any entity in the resource registry system
  # that can be used as a source for artifact synthesis. This includes resources,
  # schemas, verbs, and any future concepts that may be added.
  #
  # Implementing classes should provide methods for generating signatures and
  # supporting composition with other concepts.
  module Concept
    extend T::Sig
    extend T::Helpers
    abstract!

    requires_ancestor { Kernel }

    # Returns a unique identifier for this concept
    sig { abstract.returns(Symbol) }
    def identifier
    end
  end
end
