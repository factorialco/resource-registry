# frozen_string_literal: true
# typed: strict

require 'spec_helper'
require_relative '../lib/public/resource_struct_builder'

module ResourceRegistry
  module DtoBuilderSpec
    module Dtos
      class SimpleDto < T::Struct
        const :type, String
      end

      class NestedDto < T::Struct
        const :type, String
        const :nested, SimpleDto
      end

      class NestedValueObjectDto < T::Struct
        const :type, String
        # FIXME: bring this one here?
        # const :period, ::ValueObjects::TimeRange
      end

      class SimpleMaybeDto < T::Struct
        const :basic, String
        const :absent, Maybe[T.nilable(String)], default: Maybe.empty
        const :present, Maybe[T.nilable(Integer)], default: Maybe.empty
        const :integer, Maybe[Integer], default: Maybe.empty
      end

      class ArrayDto < T::Struct
        const :types, T::Array[SimpleDto]
        const :array, T::Array[Integer]
        const :nilable, T.nilable(T::Array[Integer])
        const :filled, T.nilable(T::Array[Integer])
        const :nested_maybes, T::Array[SimpleMaybeDto]
      end

      class NestedMaybeDto < T::Struct
        const :id, String
        const :simple_nested, SimpleDto
        const :absent_nested, Maybe[SimpleMaybeDto], default: Maybe.empty
        const :present_nested, Maybe[SimpleMaybeDto], default: Maybe.empty
      end

      class NestedNilableSimpleMaybeDto < T::Struct
        const :basic, String
        const :nested, T.nilable(SimpleMaybeDto)
      end

      class EnumTest < T::Enum
        enums do
          One = new
          Two = new
          Three = new
        end
      end

      class EnumDto < T::Struct
        const :enum_field, EnumTest
      end

      class NilableEnumDto < T::Struct
        const :enum_field, T.nilable(EnumTest)
      end

      class SetDto < T::Struct
        const :string_or_int, T.any(String, Integer)
        const :nilable, T.nilable(T.any(String, Integer))
      end
    end
  end
end

RSpec.describe ResourceRegistry::ResourceStructBuilder do
  describe '#call' do
    subject { described_class.new(dto).build(args) }

    context 'with a simple dto' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::SimpleDto }
      let(:args) { { 'type' => 'one-type' } }

      it 'is populated with the correct values' do
        expect(subject.type).to eq('one-type')
      end
    end

    context 'with a nested array dto' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::ArrayDto }
      let(:args) do
        {
          array: %w[74 73 72],
          types: [{ type: 'one-type' }, { type: 'two-type' }],
          nilable: nil,
          filled: [9, 8, 7],
          nested_maybes: [{ basic: 'basic', present: nil, integer: '17' }]
        }
      end

      it 'the array values are correctly populated' do
        result = subject
        expect(result.types.first.type).to eq 'one-type'
        expect(result.types.last.type).to eq 'two-type'
        expect(result.array).to match([74, 73, 72])
        expect(result.nilable).to be_nil
        expect(result.filled).to match([9, 8, 7])
        expect(result.nested_maybes.first.basic).to eq('basic')
        expect(result.nested_maybes.first.present).to eq(Maybe.from(nil))
        expect(result.nested_maybes.first.integer).to eq(Maybe.from(17))
      end
    end

    context 'with set of string dto' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::SetDto }
      let(:args) { { string_or_int: 'string' } }

      it 'observes values correctly' do
        result = subject
        expect(result.string_or_int).to eq('string')
        expect(result.nilable).to be_nil
      end
    end

    context 'with a nested dto' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::NestedDto }
      let(:args) { { type: 'one-type', nested: { type: 'nested-type' } } }

      it 'is populated with the correct values' do
        result = subject
        expect(result.type).to eq 'one-type'
        expect(result.nested.type).to eq 'nested-type'
      end
    end

    # ValueObjects is an internal detail of Factorial
    xcontext 'with a nested value-object dto' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::NestedValueObjectDto }
      let(:period) { ValueObjects::TimeRange.new(from: Time.zone.now, to: Time.zone.now.tomorrow) }
      let(:args) { { type: 'one-type', period: { from: period.from, to: period.to } } }

      it 'is populated with the correct values' do
        result = subject
        expect(result.type).to eq 'one-type'
        expect(result.period).to eq period
      end
    end

    context 'with a enum field dto' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::EnumDto }
      let(:args) { { enum_field: 'one' } }

      it 'is populated with the correct deserialized enum' do
        result = subject
        expect(result.enum_field).to eq(ResourceRegistry::DtoBuilderSpec::Dtos::EnumTest::One)
      end
    end

    context 'with an invalid enum field dto' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::EnumDto }
      let(:args) { { enum_field: 'lorem' } }

      it 'raises a parse error' do
        expect { subject }.to raise_error(ResourceRegistry::ResourceStructBuilder::ParseInputError)
      end
    end

    context 'with a nilable enum field dto' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::NilableEnumDto }
      let(:args) { { enum_field: nil } }

      it 'is populated with nil' do
        result = subject
        expect(result.enum_field).to be_nil
      end
    end

    context 'with maybe values' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::NestedMaybeDto }
      let(:args) do
        {
          id: 'test-id',
          simple_nested: {
            type: 'one-type'
          },
          present_nested: {
            basic: 'basic',
            present: nil,
            integer: '15'
          }
        }
      end

      it 'observes maybe values correctly' do
        result = T.let(subject, ResourceRegistry::DtoBuilderSpec::Dtos::NestedMaybeDto)
        expect(result.id).to eq('test-id')
        expect(result.simple_nested.type).to eq('one-type')

        expect(result.absent_nested).to be_absent

        expect(result.present_nested).to be_present
        simple_maybe_dto =
          T.cast(
            result.present_nested,
            Maybe::Present[ResourceRegistry::DtoBuilderSpec::Dtos::SimpleMaybeDto]
          ).value
        expect(simple_maybe_dto.basic).to eq('basic')
        expect(simple_maybe_dto.present).to eq(Maybe.from(nil))
        expect(simple_maybe_dto.integer).to eq(Maybe.from(15))
        expect(simple_maybe_dto.absent).to be_absent
      end
    end

    context 'with nested nilable values' do
      let(:dto) { ResourceRegistry::DtoBuilderSpec::Dtos::NestedNilableSimpleMaybeDto }
      let(:args) { { basic: 'one-type', nested: { basic: 'basic', present: nil, integer: '15' } } }

      it 'observes maybe values correctly' do
        result = T.let(subject, ResourceRegistry::DtoBuilderSpec::Dtos::NestedNilableSimpleMaybeDto)
        expect(result.basic).to eq('one-type')

        simple_maybe_dto =
          T.cast(result.nested, ResourceRegistry::DtoBuilderSpec::Dtos::SimpleMaybeDto)
        expect(simple_maybe_dto.basic).to eq('basic')
        expect(simple_maybe_dto.present).to eq(Maybe.from(nil))
        expect(simple_maybe_dto.integer).to eq(Maybe.from(15))
        expect(simple_maybe_dto.absent).to be_absent
      end
    end
  end
end
