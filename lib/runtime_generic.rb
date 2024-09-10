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
  include T::Generic

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
    if defined?(Tapioca::TypeVariableModule)
      puts 'Patching tapioca inference'
      # `T::Generic#type_member` just instantiates a `T::Type::TypeMember` instance and returns it.
      # We use that when registering the type member and then later return it from this method.
      return Tapioca::TypeVariableModule.new(
        T.cast(self, Module),
        Tapioca::TypeVariableModule::Type::Member,
        variance,
        blk
      ).tap do |type_variable|
        Tapioca::Runtime::GenericTypeRegistry.register_type_variable(self, type_variable)
      end
    end

    MyTypeMember.new(variance, &blk)
  end
end
