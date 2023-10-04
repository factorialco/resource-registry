# typed: strict

module ResourceRegistry
  module Graphql
    class FilterType
      extend T::Sig

      class StringFilter < GraphQL::Schema::InputObject
        argument :eq, String, required: false
        argument :not_eq, String, required: false
        argument :gt, String, required: false
        argument :lt, String, required: false
        argument :lteq, String, required: false
        argument :gteq, String, required: false
        argument :contains, String, required: false
        argument :starts_with, String, required: false
        argument :ends_with, String, required: false
        argument :in, [String], required: false
      end

      class IntegerFilter < GraphQL::Schema::InputObject
        argument :eq, Integer, required: false
        argument :not_eq, Integer, required: false
        argument :gt, Integer, required: false
        argument :lt, Integer, required: false
        argument :lteq, Integer, required: false
        argument :gteq, Integer, required: false
        argument :between, [Integer], required: false
        argument :in, [Integer], required: false
      end

      class DateFilter < GraphQL::Schema::InputObject
        argument :eq, GraphQL::Types::ISO8601Date, required: false
        argument :not_eq, GraphQL::Types::ISO8601Date, required: false
        argument :gt, GraphQL::Types::ISO8601Date, required: false
        argument :lt, GraphQL::Types::ISO8601Date, required: false
        argument :lteq, GraphQL::Types::ISO8601Date, required: false
        argument :gteq, GraphQL::Types::ISO8601Date, required: false
        argument :between, [GraphQL::Types::ISO8601Date], required: false
      end

      class DateTimeFilter < GraphQL::Schema::InputObject
        argument :eq, GraphQL::Types::ISO8601DateTime, required: false
        argument :not_eq, GraphQL::Types::ISO8601DateTime, required: false
        argument :gt, GraphQL::Types::ISO8601DateTime, required: false
        argument :lt, GraphQL::Types::ISO8601DateTime, required: false
        argument :lteq, GraphQL::Types::ISO8601DateTime, required: false
        argument :gteq, GraphQL::Types::ISO8601DateTime, required: false
        argument :between, [GraphQL::Types::ISO8601DateTime], required: false
      end

      class BooleanFilter < GraphQL::Schema::InputObject
        argument :eq, Boolean, required: false
        argument :not_eq, Boolean, required: false
      end

      sig do
        params(type: T.untyped).returns(
          T.any(
            T.class_of(ResourceRegistry::Graphql::FilterType::IntegerFilter),
            T.class_of(ResourceRegistry::Graphql::FilterType::DateFilter),
            T.class_of(ResourceRegistry::Graphql::FilterType::DateTimeFilter),
            T.class_of(ResourceRegistry::Graphql::FilterType::StringFilter),
            T.class_of(ResourceRegistry::Graphql::FilterType::BooleanFilter)
          )
        )
      end
      def self.filter_type(type)
        case [type]
        when [GraphQL::Types::Int]
          FilterType::IntegerFilter
        when [GraphQL::Types::ISO8601Date]
          FilterType::DateFilter
        when [GraphQL::Types::ISO8601DateTime]
          FilterType::DateTimeFilter
        when [GraphQL::Types::Boolean]
          FilterType::BooleanFilter
        else
          FilterType::StringFilter
        end
      end
    end
  end
end
