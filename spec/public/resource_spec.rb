# typed: false

require 'spec_helper'
require_relative '../../lib/public/resource'
require_relative '../dummy_repo'
require_relative '../dummy_capability'
require_relative '../void_capability'

RSpec.describe ResourceRegistry::Resource do
  let(:capability) { DummyCapability.new }
  let(:dummy_struct) { T::Struct }
  let(:schema) do
    SchemaRegistry::Schema.new(
      name: 'employees',
      namespace: 'employees',
      properties: [
        SchemaRegistry::Property.new(
          name: 'foo',
          types: [SchemaRegistry::PropertyType::String],
          required: true
        )
      ]
    )
  end
  let(:verbs) do
    { copy: ResourceRegistry::Verb.new(id: :copy, dto_raw: dummy_struct.to_s, schema: schema) }
  end
  let(:resource) do
    ResourceRegistry::Resource.new(
      repository_raw: DummyRepo.to_s,
      description: 'foo',
      schema: schema,
      verbs: verbs,
      capabilities: {
        dummy_capability: capability
      }
    )
  end

  it { expect(resource.schema).to be_a(SchemaRegistry::Schema) }
  it { expect(resource.schema.properties.first.name).to eq 'foo' }

  describe '#collection_name' do
    it { expect(resource.collection_name).to eq('dummy_repos') }
  end

  describe '#path' do
    it { expect(resource.path).to eq('dummyrepo/dummy_repo') }
  end

  describe '#dump' do
    it { expect(resource.dump).to include_json(description: 'foo') }
  end

  describe '#load' do
    let(:spec) { resource.dump }
    let(:configuration) do
      ResourceRegistry::Configuration.new.tap do |conf|
        conf.register_capability(:dummy_capability, DummyCapability)
      end
    end

    subject { described_class.load(spec, configuration: configuration) }

    it { expect(subject).to be_a(described_class) }

    describe 'paginateable' do
      context 'when the paginateable property is not provided' do
        it 'is true by default' do
          expect(subject.paginateable).to be true
        end
      end

      context 'when the paginateable property is provided' do
        before { spec['paginateable'] = false }

        it 'uses the value from the resource definition' do
          expect(subject.paginateable).to be false
        end
      end
    end

    describe '#capability!' do
      let(:feature) { DummyCapability }

      subject { resource.capability!(feature) }

      it { expect(subject).to eq(capability) }

      context 'The resource don\'t have such capability' do
        let(:feature) { VoidCapability }

        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end
  end
end
