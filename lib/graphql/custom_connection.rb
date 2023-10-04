# typed: true

module ResourceRegistry
  module Graphql
    class CustomConnection < GraphQL::Types::Relay::BaseConnection
      extend T::Sig

      class DangerousDirective < GraphQL::Schema::Directive
        graphql_name 'dangerous'
        argument :reason, String
        locations(FIELD_DEFINITION)
        description 'warns about fields that should be avoided and states the reason'
      end

      edges_nullable(false)
      edge_nullable(false)
      node_nullable(false)
      has_nodes_field(true)

      field :total_count,
            Integer,
            directives: {
              DangerousDirective => {
                reason:
                  # rubocop:disable Layout/LineLength
                  'Do not use this for cursor pagination except extremely necessary. It makes another query if your result is an ActiveRecord Relation, thereby increasing latency'
                # rubocop:enable Layout/LineLength
              }
            }

      sig { overridable.returns(T.nilable(Integer)) }
      def total_count
        object.total
      rescue NoMethodError
        object.items.size
        # in the case of relationships
      end
    end
  end
end
