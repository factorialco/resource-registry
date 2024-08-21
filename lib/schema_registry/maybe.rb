# typed: strict
# frozen_string_literal: true

require_relative('../runtime_generic')

# Represents an instance of an object that may or may not be present. This can be useful in certain
# cases where `nil` represents a valid value instead of an absent value, i.e. update DTOs.
#
# An useful way to think about `Maybe` is as a collection, like `Array` or `Set` but that can only
# hold a maximum of 1 elements at a time.
module Maybe
  extend T::Sig
  extend T::Generic
  extend RuntimeGeneric
  include Kernel
  interface!

  # NOTE: Beware of implementing a `Maybe#value` method in the interface so you can call it without
  # type safety. >:(

  Value = type_member(:out) { { upper: BasicObject } }

  sig { abstract.returns(T::Boolean) }
  # `true` if this `Maybe` contains a value, `false` otherwise.
  def present?; end

  sig { abstract.returns(T::Boolean) }
  # `true` if this `Maybe` does not contain a value, `false` otherwise.
  def absent?; end

  sig { abstract.returns(T::Boolean) }
  # `true` if this `Maybe` does not contain a value, `false` otherwise.
  #
  # alias of `#absent`
  def empty?; end

  sig do
    abstract
      .type_parameters(:Default)
      .params(default: T.type_parameter(:Default))
      .returns(T.any(Value, T.type_parameter(:Default)))
  end
  # Returns the value if there's one, else, it returns the provided default.
  def or_default(default); end

  sig do
    abstract
      .type_parameters(:Return)
      .params(_block: T.proc.params(v: Value).returns(T.type_parameter(:Return)))
      .returns(T.nilable(T.type_parameter(:Return)))
  end
  # Executes the given code block if there's a value present, the code block will receive the value
  # as an argument and the method will return whatever the code block returns or `nil` if no value
  # present.
  def when_present(&_block); end

  sig do
    abstract
      .type_parameters(:Return)
      .params(_block: T.proc.returns(T.type_parameter(:Return)))
      .returns(T.nilable(T.type_parameter(:Return)))
  end
  # Executes the given code block if a value isn't present, returns whatever the code block returned
  # or `nil` if if the value was present.
  def when_absent(&_block); end

  sig do
    abstract.params(_block: T.proc.params(value: Value).returns(T::Boolean)).returns(Maybe[Value])
  end
  # Evaluate the specified block passing it the value if one is present, if the block returns true,
  # returns an instance containing the same value, if the block returns false, returns an empty
  # instance. If the instance is already empty, it returns an empty instance and the block is not
  # evaluated.
  #
  # This is analogous to the `Array#filter` method if the `Maybe` class were an `Array` that can
  # hold one element at maximum.
  def filter(&_block); end

  sig do
    abstract
      .type_parameters(:Default)
      .params(
        _block: T.proc.params(value: Value).returns(T.all(BasicObject, T.type_parameter(:Default)))
      )
      .returns(Maybe[T.all(BasicObject, T.type_parameter(:Default))])
  end
  # Evaluate the specified block passing it the value if one is present, returns an instance
  # containing the result of the evaluation. If no element is present, returns an empty instance.
  #
  # This is analogous to the `Array#map` method if the `Maybe` class were an `Array` that can
  # hold one element at maximum.
  def map(&_block); end
end
