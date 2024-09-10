# typed: true

require 'tapioca'
require 'tapioca/gem/listeners/base'
require 'tapioca/sorbet_ext/generic_name_patch'
require 'tapioca/runtime/reflection'
require 'tapioca/runtime/generic_type_registry'
require 'tapioca/gem/listeners/sorbet_type_variables'

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

  def [](inner_type)
    T::Types::Simple.new(inner_type)
  end

  def type_member(variance = :invariant, &blk)
    # `T::Generic#type_member` just instantiates a `T::Type::TypeMember` instance and returns it.
    # We use that when registering the type member and then later return it from this method.
    #
    # Dear developer, This part was adapted from tapioca so it can keep
    # generating proper RBIs for this ad-hoc generics, Genar
    Tapioca::TypeVariableModule.new(
      T.cast(self, Module),
      Tapioca::TypeVariableModule::Type::Member,
      variance,
      blk
    ).tap do |type_variable|
      Tapioca::Runtime::GenericTypeRegistry.register_type_variable(self, type_variable)
    end
  end
end
