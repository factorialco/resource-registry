# typed: true
module ResourceRegistry
  module Graphql
    class FinderDirective < GraphQL::Schema::Directive
      graphql_name 'finder'
      locations(FIELD_DEFINITION)
      description 'This field returns data from a Type given an ID'
    end
  end
end
