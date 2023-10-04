# typed: strict

module ResourceRegistry
  module Graphql
    class SchemaArgument < T::Struct
      const :name, String
      # rubocop:disable Sorbet/ForbidUntypedStructProps
      # Types are deduced at runtime and this makes it incredibly tricky
      # to satify the struct type rule
      const :type, T.untyped
      # rubocop:enable Sorbet/ForbidUntypedStructProps
      const :required, T::Boolean, default: false
    end
  end
end
