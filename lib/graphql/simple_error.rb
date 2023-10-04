# typed: strict

module ResourceRegistry
  module Graphql
    class SimpleError < T::Struct
      const :type, String
      const :message, String
    end
  end
end
