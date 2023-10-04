# typed: strict

module ResourceRegistry
  module Graphql
    class BaseObject < GraphQL::Schema::Object
      extend T::Sig

      field_class BaseField

      sig { params(obj: T.untyped, ctx: T.untyped).returns(T.untyped) }
      def self.authorized_new(obj, ctx)
        new(obj, ctx)
      end
    end
  end
end
