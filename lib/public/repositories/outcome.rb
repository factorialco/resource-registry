# typed: true

module ResourceRegistry
  module Repositories
    module Outcome
      extend T::Sig
      extend T::Helpers
      extend T::Generic

      Elem = type_member(:out)

      interface!
    end
  end
end
