# typed: strict

module ResourceRegistry::Repositories::Base
  extend ::RuntimeGeneric
  extend T::Generic

  Entity = type_member(:out) {{ upper: T::Struct }}
end

module Maybe
  extend ::RuntimeGeneric
  extend T::Generic

  Value = type_member(:out) { { upper: BasicObject } }

  # @abstract
  #
  # source://resource_registry//lib/schema_registry/maybe.rb#106
  sig { abstract.returns(T::Boolean) }
  def absent?; end

  # @abstract
  #
  # source://resource_registry//lib/schema_registry/maybe.rb#112
  sig { abstract.returns(T::Boolean) }
  def empty?; end

  # @abstract
  #
  # source://resource_registry//lib/schema_registry/maybe.rb#154
  sig { abstract.params(_block: T.proc.params(value: T.untyped).returns(T::Boolean)).returns(Maybe[T.untyped]) }
  def filter(&_block); end

  # @abstract
  #
  # source://resource_registry//lib/schema_registry/maybe.rb#169
  sig do
    abstract
      .type_parameters(:Default)
      .params(
        _block: T.proc.params(value: T.untyped).returns(T.all(::BasicObject, T.type_parameter(:Default)))
      ).returns(Maybe[T.all(::BasicObject, T.type_parameter(:Default))])
  end
  def map(&_block); end

  # @abstract
  #
  # source://resource_registry//lib/schema_registry/maybe.rb#121
  sig do
    abstract
      .type_parameters(:Default)
      .params(
        default: T.type_parameter(:Default)
      ).returns(T.any(T.type_parameter(:Default), T.untyped))
  end
  def or_default(default); end

  # @abstract
  #
  # source://resource_registry//lib/schema_registry/maybe.rb#102
  sig { abstract.returns(T::Boolean) }
  def present?; end

  # @abstract
  #
  # source://resource_registry//lib/schema_registry/maybe.rb#142
  sig do
    abstract
      .type_parameters(:Return)
      .params(
        _block: T.proc.returns(T.type_parameter(:Return))
      ).returns(T.nilable(T.type_parameter(:Return)))
  end
  def when_absent(&_block); end

  # @abstract
  #
  # source://resource_registry//lib/schema_registry/maybe.rb#132
  sig do
    abstract
      .type_parameters(:Return)
      .params(
        _block: T.proc.params(v: T.untyped).returns(T.type_parameter(:Return))
      ).returns(T.nilable(T.type_parameter(:Return)))
  end
  def when_present(&_block); end

  class << self
    # source://resource_registry//lib/schema_registry/maybe.rb#75
    sig { returns(Maybe::Absent) }
    def absent; end

    # source://resource_registry//lib/schema_registry/maybe.rb#61
    sig { returns(Maybe::Absent) }
    def empty; end

    # source://resource_registry//lib/schema_registry/maybe.rb#96
    sig do
      type_parameters(:Value)
        .params(
          value: T.all(::BasicObject, T.type_parameter(:Value))
        ).returns(Maybe[T.all(::BasicObject, T.type_parameter(:Value))])
    end
    def from(value); end

    # source://resource_registry//lib/schema_registry/maybe.rb#68
    sig { returns(Maybe::Absent) }
    def none; end

    # source://resource_registry//lib/schema_registry/maybe.rb#41
    sig do
      type_parameters(:Key)
        .params(
          input: T::Hash[T.type_parameter(:Key), T.untyped]
        ).returns(T::Hash[T.type_parameter(:Key), T.untyped])
    end
    def strip(input); end

    sig do
      type_parameters(:Value)
        .params(value: T.all(BasicObject, T.type_parameter(:Value)))
        .returns(Maybe[T.all(BasicObject, T.type_parameter(:Value))])
    end
    # Creates an instance containing the specified value.
    # Necessary to make this work with sorbet-coerce
    def new(value); end

  end
end

# Class used to represent the empty case
#
# source://resource_registry//lib/schema_registry/maybe/absent.rb#6
class Maybe::Absent
  extend T::Generic
  include ::Maybe

  final!

  Value = type_member { { fixed: T.noreturn } }

  # source://resource_registry//lib/schema_registry/maybe/absent.rb#77
  sig(:final) { override.params(other: ::BasicObject).returns(T::Boolean) }
  def ==(other); end

  # source://resource_registry//lib/schema_registry/maybe/absent.rb#20
  sig(:final) { override.returns(::TrueClass) }
  def absent?; end

  # source://resource_registry//lib/schema_registry/maybe/absent.rb#25
  sig(:final) { override.returns(::TrueClass) }
  def empty?; end

  sig(:final) do
    override
      .type_parameters(:Default)
      .params(default: T.type_parameter(:Default))
      .returns(T.type_parameter(:Default))
  end
  def or_default(default); end

  sig(:final) do
    override
      .type_parameters(:Return)
      .params(_block: T.proc.params(v: Value).returns(T.type_parameter(:Return)))
      .returns(T.nilable(T.type_parameter(:Return)))
  end
  def when_present(&_block); end

  sig(:final) do
    override
      .type_parameters(:Return)
      .params(_block: T.proc.returns(T.type_parameter(:Return)))
      .returns(T.nilable(T.type_parameter(:Return)))
  end
  def when_absent(&_block); end

  sig(:final) do
    override.params(_block: T.proc.params(value: Value).returns(T::Boolean)).returns(Maybe[Value])
  end
  def filter(&_block); end

  sig(:final) do
    override
      .type_parameters(:Default)
      .params(_block: T.proc.params(value: Value).returns(T.type_parameter(:Default)))
      .returns(Maybe[T.all(BasicObject, T.type_parameter(:Default))])
  end
  def map(&_block); end

  sig(:final) { override.params(other: BasicObject).returns(T::Boolean) }
  def ==(other); end
end

class Maybe::Present
  extend T::Generic
  include ::Maybe

  final!

  Value = type_member(:out) { { upper: BasicObject } }

  sig(:final) { params(value: Value).void }
  def initialize(value); end

  sig(:final) { override.returns(TrueClass) }
  def present?; end

  sig(:final) { override.returns(FalseClass) }
  def absent?; end

  sig(:final) { override.returns(FalseClass) }
  def empty?; end

  sig(:final) do
    override.type_parameters(:Default).params(_default: T.type_parameter(:Default)).returns(Value)
  end
  def or_default(_default); end

  sig(:final) do
    override
      .type_parameters(:Return)
      .params(_block: T.proc.params(v: Value).returns(T.type_parameter(:Return)))
      .returns(T.nilable(T.type_parameter(:Return)))
  end
  def when_present(&_block); end

  sig(:final) do
    override
      .type_parameters(:Return)
      .params(_block: T.proc.returns(T.type_parameter(:Return)))
      .returns(T.nilable(T.type_parameter(:Return)))
  end
  def when_absent(&_block); end

  sig(:final) do
    override.params(_block: T.proc.params(value: Value).returns(T::Boolean)).returns(Maybe[Value])
  end
  def filter(&_block); end

  sig(:final) do
    override
      .type_parameters(:Default)
      .params(
        _block:
          T.proc.params(value: Value).returns(T.all(BasicObject, T.type_parameter(:Default)))
      )
      .returns(Maybe[T.all(BasicObject, T.type_parameter(:Default))])
  end
  def map(&_block); end

  sig(:final) { override.params(other: BasicObject).returns(T::Boolean) }
  def ==(other); end
end
