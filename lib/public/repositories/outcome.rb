# typed: true

module ResourceRegistry
  module Repositories
    module Outcome
      extend T::Sig
      extend T::Helpers
      extend T::Generic

      Elem = type_member(:out)

      abstract!

      sig { abstract.returns(Elem) }
      def unwrap!; end
    end
  end
end
