# typed: true

module ResourceRegistry
  module Graphql
    class NamespaceDirective < GraphQL::Schema::Directive
      graphql_name 'namespace'
      locations(FIELD_DEFINITION)
      description 'This field is an empty object used as a namespace'
    end
  end
end
