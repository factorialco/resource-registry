# typed: strict
# frozen_string_literal: true

require_relative('../runtime_generic')
require_relative('maybe/absent')
require_relative('maybe/present')

# Represents an instance of an object that may or may not be present. This can be useful in certain
# cases where `nil` represents a valid value instead of an absent value, i.e. update DTOs.
#
# An useful way to think about `Maybe` is as a collection, like `Array` or `Set` but that can only
# hold a maximum of 1 elements at a time.
#
# NOTE: Beware of implementing a `Maybe#value` method in the interface so you can call it without
# type safety. >:(
module Maybe
  extend T::Sig
  extend RuntimeGeneric
  include Kernel
  interface!

  sig do
    type_parameters(:Key)
      .params(input: T::Hash[T.type_parameter(:Key), T.untyped])
      .returns(T::Hash[T.type_parameter(:Key), T.untyped])
  end
  # You can use this method to easily transform a Hash with `Maybe` values into one without them,
  # filtering out `Maybe` instances that are empty and unwrapping the present ones.
  #
  # Given a hash containing `Maybe` instances, returns a hash with only the values that are present.
  # It also unwraps the present values.
  #
  # For convenience, it also recursively serializes nested T::Structs and strips nested hashes,
  # arrays and sets.
  #
  # ```ruby
  #   Maybe.strip({ a: Maybe.from(1), b: Maybe.empty, c: Maybe.from(3) })
  #   # => { a: 1, c: 3 }
  # ```
  def self.strip(input) # rubocop:disable Metrics/PerceivedComplexity
    input
      .reject { |_key, value| value == Maybe.empty }
      .to_h do |key, value|
        unwrapped = value.is_a?(Maybe::Present) ? value.value : value
        enumerated =
          if unwrapped.is_a?(Array) || unwrapped.is_a?(Set)
            unwrapped.map { |v| v.is_a?(T::Struct) ? Maybe.strip(v.serialize) : Maybe.strip(v) }
          else
            unwrapped
          end
        serialized = enumerated.is_a?(T::Struct) ? enumerated.serialize : enumerated
        stripped = serialized.is_a?(Hash) ? Maybe.strip(serialized) : serialized

        [key, stripped]
      end
  end

  sig { returns(Absent) }
  # Creates an empty instance.
  def self.empty
    Absent.new
  end

  sig { returns(Absent) }
  # Creates an empty instance.
  # Alias for self.empty
  def self.none
    empty
  end

  sig { returns(Absent) }
  # Creates an empty instance.
  # Alias for self.empty
  def self.absent
    empty
  end

  sig do
    type_parameters(:Value)
      .params(value: T.all(BasicObject, T.type_parameter(:Value)))
      .returns(Maybe[T.all(BasicObject, T.type_parameter(:Value))])
  end
  # Creates an instance containing the specified value.
  # Necessary to make this work with sorbet-coerce
  def self.new(value)
    from(value)
  end

  sig do
    type_parameters(:Value)
      .params(value: T.all(BasicObject, T.type_parameter(:Value)))
      .returns(Maybe[T.all(BasicObject, T.type_parameter(:Value))])
  end
  # Creates an instance containing the specified value.
  def self.from(value)
    Present[T.all(BasicObject, T.type_parameter(:Value))].new(value)
  end

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
