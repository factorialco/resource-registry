# typed: strict

module ResourceRegistry
  module Graphql
    module Introspection
      class DynamicFields < GraphQL::Introspection::DynamicFields
        extend T::Sig

        # Hack to disable `DynamicFields.authorize`:
        # https://github.com/rmosolgo/graphql-ruby/pull/3446
        sig { params(obj: T.untyped, ctx: T.untyped).returns(T.untyped) }
        def self.authorized_new(obj, ctx)
          new(obj, ctx)
        end
      end
    end
  end
end
