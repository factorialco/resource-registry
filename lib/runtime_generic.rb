# typed: true

# This module allows using type introspection to serialize/deserialize custom generics in
# T::Structs.
#
# While Sorbet can answer questions about types in T::Structs and arrays, it erases generic types
# at runtime. To support custom generics, we must manually preserve the type information with
# which they were declared.
#
# Use this module instead of `T::Generic` to create generic types with runtime type information.
module RuntimeGeneric
  extend T::Helpers
  extend T::Sig
  extend T::Generic

  class TypedGeneric < T::Types::Simple
    extend T::Sig

    def name
      "#{raw_type.name}[#{inner_type.name}]"
    end

    def initialize(raw_type, inner_type)
      super(raw_type)
      @inner_type = inner_type
    end

    attr_reader :inner_type
  end

  class MyTypeMember < T::Types::TypeMember
    def initialize(variance, &type_proc)
      super(variance)
      @type_proc = type_proc
    end

    def inner_type
      @inner_type ||= @type_proc.call
    end
  end

  def [](inner_type)
    RuntimeGeneric::TypedGeneric.new(self, inner_type)
  end

  def type_member(variance = :invariant, &blk)
    MyTypeMember.new(variance, &blk)
  end
end
