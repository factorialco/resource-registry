# typed: strict
# frozen_string_literal: true

module Maybe
  # Class used to represent the empty case
  class Absent
    extend T::Sig
    extend T::Generic
    include Maybe
    final!

    sig(:final) { override.returns(FalseClass) }
    def present?
      false
    end

    sig(:final) { override.returns(TrueClass) }
    def absent?
      true
    end

    sig(:final) { override.returns(TrueClass) }
    def empty?
      absent?
    end

    sig(:final) do
      override
        .type_parameters(:Default)
        .params(default: T.type_parameter(:Default))
        .returns(T.type_parameter(:Default))
    end
    def or_default(default)
      default
    end

    sig(:final) do
      override
        .type_parameters(:Return)
        .params(_block: T.proc.params(v: Value).returns(T.type_parameter(:Return)))
        .returns(T.nilable(T.type_parameter(:Return)))
    end
    def when_present(&_block)
      nil
    end

    sig(:final) do
      override
        .type_parameters(:Return)
        .params(_block: T.proc.returns(T.type_parameter(:Return)))
        .returns(T.nilable(T.type_parameter(:Return)))
    end
    def when_absent(&_block)
      yield
    end

    sig(:final) do
      override.params(_block: T.proc.params(value: Value).returns(T::Boolean)).returns(Maybe[Value])
    end
    def filter(&_block)
      self
    end

    sig(:final) do
      override
        .type_parameters(:Default)
        .params(_block: T.proc.params(value: Value).returns(T.type_parameter(:Default)))
        .returns(Maybe[T.all(BasicObject, T.type_parameter(:Default))])
    end
    def map(&_block)
      self
    end

    sig(:final) { override.params(other: BasicObject).returns(T::Boolean) }
    def ==(other)
      self.class === other # rubocop:disable Style/CaseEquality
    end
  end
end
