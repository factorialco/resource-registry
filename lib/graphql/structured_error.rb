# typed: strict

module ResourceRegistry
  module Graphql
    class StructuredError < T::Struct
      const :field, String
      const :messages, T::Array[String]
    end
  end
end
