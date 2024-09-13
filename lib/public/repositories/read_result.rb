# typed: true

require_relative './output_contexts/page_info_dto'

module ResourceRegistry
  module Repositories
    module ReadResult
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      Entity = type_member { { upper: T::Struct } }

      interface!

      sig { abstract.returns(T.untyped) }
      def entities; end

      sig { abstract.returns(T.untyped) }
      def projections; end

      sig { abstract.returns(OutputContexts::PageInfoDto) }
      def page_info; end

      sig { abstract.returns(T.nilable(Integer)) }
      def total_count; end
    end
  end
end
