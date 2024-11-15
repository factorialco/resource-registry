# typed: strict
# frozen_string_literal: true

module Maybe
  # Class used to represent the case when a value is available
  class Present
    extend T::Sig
    extend T::Generic
    include Maybe
    # final! FIXME

    Value = type_member(:out) { { upper: BasicObject } }

    sig(:final) { params(value: Value).void }
    def initialize(value)
      @value = value
    end

    sig(:final) { override.returns(TrueClass) }
    def present?
      true
    end

    sig(:final) { override.returns(FalseClass) }
    def absent?
      false
    end

    sig(:final) { override.returns(FalseClass) }
    def empty?
      absent?
    end

    sig(:final) do
      override
        .type_parameters(:Default)
        .params(_default: T.type_parameter(:Default))
        .returns(Value)
    end
    def or_default(_default)
      value
    end

    sig(:final) do
      override
        .type_parameters(:Return)
        .params(
          _block: T.proc.params(v: Value).returns(T.type_parameter(:Return))
        )
        .returns(T.nilable(T.type_parameter(:Return)))
    end
    def when_present(&_block)
      yield value
    end

    sig(:final) do
      override
        .type_parameters(:Return)
        .params(_block: T.proc.returns(T.type_parameter(:Return)))
        .returns(T.nilable(T.type_parameter(:Return)))
    end
    def when_absent(&_block)
      nil
    end

    sig(:final) do
      override
        .params(_block: T.proc.params(value: Value).returns(T::Boolean))
        .returns(Maybe[Value])
    end
    def filter(&_block)
      return self if yield value

      Absent.new
    end

    sig(:final) do
      override
        .type_parameters(:Default)
        .params(
          _block:
            T
              .proc
              .params(value: Value)
              .returns(T.all(BasicObject, T.type_parameter(:Default)))
        )
        .returns(Maybe[T.all(BasicObject, T.type_parameter(:Default))])
    end
    def map(&_block)
      mapped = yield value
      Present[T.all(BasicObject, T.type_parameter(:Default))].new(mapped)
    end

    sig(:final) { override.params(other: BasicObject).returns(T::Boolean) }
    def ==(other)
      return false unless self.class === other # rubocop:disable Style/CaseEquality

      value == other.value
    end

    sig(:final) { returns(Value) }
    attr_reader :value
  end
end
