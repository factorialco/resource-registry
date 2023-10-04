# typed: strict

module ResourceRegistry
  module Graphql
    class BaseMutation < GraphQL::Schema::Mutation
      field_class BaseField
    end
  end
end
