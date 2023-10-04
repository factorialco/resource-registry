# typed: true

module ResourceRegistry
  module Graphql
    class CustomEdge < GraphQL::Types::Relay::BaseEdge
      node_nullable(false)
    end
  end
end
