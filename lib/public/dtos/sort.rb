# typed: strict

module ResourceRegistry
  module Dtos
    class Sort < T::Struct
      const :field, String
      const :order, Symbol
    end
  end
end
