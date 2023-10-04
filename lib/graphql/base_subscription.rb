# typed: true
module ResourceRegistry
  module Graphql
    class BaseSubscription < GraphQL::Schema::Subscription
      object_class BaseObject
      field_class BaseField
    end
  end
end
