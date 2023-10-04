# typed: strict

module ResourceRegistry
  module Graphql
    class ResolvableDirective < GraphQL::Schema::Directive
      graphql_name 'resolvable'
      locations(FIELD_DEFINITION)
      description 'Lets us know if we can search, sort and filter by this field'
    end
  end
end
