# typed: strict

module ResourceRegistry
  module Graphql
    class SortType < GraphQL::Schema::InputObject
      description 'The sorting field path and order'
      argument :field, String, 'The column name to sort by in relation to the present table'
      argument :order, String, 'The order of sorting'
    end
  end
end
