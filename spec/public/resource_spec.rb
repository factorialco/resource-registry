# typed: strict

require 'rails_helper'

RSpec.describe ResourceRegistry::Resource do
  let(:capability) { Graphql::Capability.new }
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
      repository_raw: Employees::Repositories::Employees.to_s,
      description: 'foo',
      schema: schema,
      verbs: verbs,
      capabilities: {
        graphql: capability
      }
    )
  end

  it { expect(resource.schema).to be_a(SchemaRegistry::Schema) }
  it { expect(resource.schema.properties.first.name).to eq 'foo' }

  describe '#collection_name' do
    it { expect(resource.collection_name).to eq('employees') }
  end

  describe '#path' do
    it { expect(resource.path).to eq('employees/employee') }
  end

  describe '#dump' do
    it { expect(resource.dump).to include_json(description: 'foo') }
  end

  describe '#load' do
    let(:spec) { resource.dump }

    subject { described_class.load(spec) }

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
      let(:feature) { Graphql::Capability }

      subject { resource.capability!(feature) }

      it { expect(subject).to eq(capability) }

      context 'The resource don\'t have such capability' do
        let(:feature) { ResourceRegistry::Capabilities::Rest }

        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end
  end
end
