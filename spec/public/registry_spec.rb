# typed: strict

RSpec.describe ResourceRegistry::Registry do
  let(:resources) { [resource] }
  let(:registry) { described_class.new(resources: resources) }
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
  let(:resource) do
    ResourceRegistry::Resource.new(
      repository_raw: Employees::Repositories::Employees.to_s,
      capabilities: {
        rest: ResourceRegistry::Capabilities::Rest.new,
        power_bi: ResourceRegistry::Capabilities::PowerBi.new
      },
      verbs: {
      },
      schema: schema
    )
  end
  let(:identifier) { resource.identifier.to_s }

  describe '#initialize' do
    let(:resources) { [resource, resource] }

    it 'not allow duplicated identifiers' do
      expect { registry }.to raise_error(ResourceRegistry::Registry::DuplicatedIdentifierError)
    end
  end

  describe '#fetch' do
    it { expect(registry.fetch(identifier)).to be(resource) }
  end

  describe '#fetch_all' do
    it { expect(registry.fetch_all).to eq({ identifier => resource }) }
  end

  describe '#fetch_for_repository' do
    it do
      expect(registry.fetch_for_repository(Employees::Repositories::Employees)).to(eq(resource))
    end
  end

  describe '#fetch_with_capabilities' do
    let(:features) { [ResourceRegistry::Capabilities::PowerBi] }

    subject { registry.fetch_with_capabilities(*features) }

    it { expect(subject.size).to eq(1) }

    context 'the resource doesn\t have the capability' do
      let(:features) { [Graphql::Capability] }

      it { expect(subject.size).to eq(0) }
    end
  end
end
