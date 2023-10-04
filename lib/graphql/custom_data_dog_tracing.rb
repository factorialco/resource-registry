# typed: true
require 'ddtrace'

module ResourceRegistry
  module Graphql
    class CustomDataDogTracing < GraphQL::Tracing::DataDogTracing
      extend T::Sig

      BLOCKLIST = Set[].freeze

      sig { params(platform_key: String, key: String, data: T.untyped).returns(T.untyped) }
      def platform_trace(platform_key, key, data)
        if BLOCKLIST.member?(key)
          yield
        else
          super
        end
      end
    end
  end
end
