# typed: strict

module ResourceRegistry
  module Graphql
    class SchemaField < T::Struct
      const :name, String
      # rubocop:disable Sorbet/ForbidUntypedStructProps
      # Types are deduced at runtime and this makes it incredibly tricky
      # to satify the struct type rule
      const :type, T.untyped
    end
  end
end
