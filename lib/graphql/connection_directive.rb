# typed: true

module ResourceRegistry
  module Graphql
    class ConnectionDirective < GraphQL::Schema::Directive
      graphql_name 'connection'
      locations(FIELD_DEFINITION)
      description 'This field is a paginated resource'
    end
  end
end
