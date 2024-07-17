# typed: strict

module SchemaRegistry
  class FilterField < T::Struct
    extend T::Sig

    const :name, String
    const :resolver, T.nilable(T::Hash[Symbol, String])
    const :type, PropertyType
    const :in_memory, T::Boolean, default: false
  end
end
