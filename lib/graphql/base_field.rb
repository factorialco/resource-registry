# typed: strict

module ResourceRegistry
  module Graphql
    class BaseField < GraphQL::Schema::Field
      extend T::Sig

      sig do
        params(query: T.untyped, nodes: T.untyped, child_complexity: T.untyped).returns(Integer)
      end
      def calculate_complexity(query:, nodes:, child_complexity:)
        if connection?
          20
        else
          super
        end
      end
    end
  end
end
