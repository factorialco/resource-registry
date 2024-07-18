# typed: strict

require 'rails_helper'

RSpec.describe ResourceRegistry::OpenapiSpecificationGenerator do
  let(:schema) do
    SchemaRegistry::Schema.new(
      name: 'employees',
      namespace: 'employees',
      properties: schema_properties
    )
  end
  let(:schema_properties) do
    [
      SchemaRegistry::Property.new(
        name: 'foo',
        types: [SchemaRegistry::PropertyType::String],
        required: true
      )
    ]
  end
  let(:dummy_dto) { Class.new(T::Struct) }
  let(:verbs) do
    { read: ResourceRegistry::Verb.new(id: :read, dto_raw: dummy_dto.to_s, schema: verb_schema) }
  end
  let(:capabilities) do
    { rest: ResourceRegistry::Capabilities::Rest.new(is_public: true, private_verbs: []) }
  end
  let(:prop) do
    SchemaRegistry::Property.new(
      name: 'id',
      types: [SchemaRegistry::PropertyType::Integer],
      description: 'It does something',
      required: true
    )
  end

  let(:verb_schema) do
    SchemaRegistry::Schema.new(
      name: 'employees',
      namespace: 'employees',
      properties: [
        SchemaRegistry::Property.new(
          name: 'id',
          types: [SchemaRegistry::PropertyType::Integer],
          required: true
        ),
        SchemaRegistry::Property.new(
          name: 'name',
          types: [SchemaRegistry::PropertyType::String],
          required: true
        )
      ],
      raw_json_schema: {
        'Create' => {
          'type' => 'object',
          'properties' => {
            'id' => {
              'type' => 'integer',
              'typedef' => Integer,
              'description' => 'id of the resource',
              'example' => 1
            },
            'name' => {
              'type' => 'string',
              'typedef' => String,
              'description' => 'name of the resource',
              'example' => 'John Doe'
            }
          }
        }
      }
    )
  end
  let(:resource) do
    ResourceRegistry::Resource.new(
      repository_raw: ApiPublic::Repositories::Core::ApiKeys.to_s,
      verbs: verbs,
      schema: schema,
      capabilities: capabilities
    )
  end

  let(:output) { subject.call }

  subject { described_class.new(resources: [resource]) }

  describe '#call' do
    it 'pluralizes the resource' do
      expect(subject.call.to_s).to match('/v2/resources/api_public/api_keys')
    end

    it 'gives disctinct names for read operations' do
      paths = subject.call['paths']
      index = paths['/api/v2/resources/api_public/api_keys']['get']
      show = paths['/api/v2/resources/api_public/api_keys/{id}']['get']

      expect(index['description']).to eq('Reads all Api keys')
      expect(index['description']).to eq(index['summary'])

      expect(show['description']).to eq('Reads a single Api key')
      expect(show['description']).to eq(show['summary'])
    end

    context 'when create' do
      let(:verbs) do
        {
          create:
            ResourceRegistry::Verb.new(id: :create, dto_raw: dummy_dto.to_s, schema: verb_schema)
        }
      end

      it 'gives disctinct names for create operations' do
        paths = subject.call['paths']
        create = paths['/api/v2/resources/api_public/api_keys']['post']

        expect(create['description']).to eq('Creates a/an Api key')
        expect(create['description']).to eq(create['summary'])
      end

      it 'generates request body properties' do
        paths = subject.call['paths']
        create = paths['/api/v2/resources/api_public/api_keys']['post']
        properties = create['requestBody']['content']['application/json']['schema']['properties']
        id = properties['id']
        name = properties['name']

        expect(id['description']).to eq('id of the resource')
        expect(id['example']).to eq(1)
        expect(name['description']).to eq('name of the resource')
        expect(name['example']).to eq('John Doe')
      end
    end

    context 'when update' do
      let(:verbs) do
        {
          update:
            ResourceRegistry::Verb.new(id: :update, dto_raw: dummy_dto.to_s, schema: verb_schema)
        }
      end

      it 'gives disctinct names for update operations' do
        paths = subject.call['paths']
        update = paths['/api/v2/resources/api_public/api_keys/{id}']['put']

        expect(update['description']).to eq('Updates a/an Api key')
        expect(update['description']).to eq(update['summary'])
      end
    end

    context 'when delete' do
      let(:verbs) do
        {
          delete:
            ResourceRegistry::Verb.new(id: :delete, dto_raw: dummy_dto.to_s, schema: verb_schema)
        }
      end

      it 'gives disctinct names for delete operations' do
        paths = subject.call['paths']
        delete = paths['/api/v2/resources/api_public/api_keys/{id}']['delete']

        expect(delete['description']).to eq('Deletes a/an Api key')
        expect(delete['description']).to eq(delete['summary'])
      end
    end

    context 'parameters types' do
      it do
        parameters = output['paths'].values.first['get']['parameters']

        expect(parameters.first['schema']['type']).to eq 'integer'
        expect(parameters.last['schema']['type']).to eq 'string'
      end
    end

    context 'parameter description' do
      let(:verb_schema) do
        SchemaRegistry::Schema.new(
          name: 'employees',
          namespace: 'employees',
          properties: [
            SchemaRegistry::Property.new(
              name: 'id',
              types: [SchemaRegistry::PropertyType::Integer],
              description: 'It does something',
              required: true
            ),
            SchemaRegistry::Property.new(
              name: 'name',
              types: [SchemaRegistry::PropertyType::String],
              description: 'It does something',
              required: true
            )
          ]
        )
      end

      it do
        parameters = output['paths'].values.first['get']['parameters']

        expect(parameters.last['description']).to eq 'It does something'
      end
    end

    context 'parameter type when array' do
      let(:verb_schema) do
        SchemaRegistry::Schema.new(
          name: 'goals',
          namespace: 'goals',
          properties: [
            SchemaRegistry::Property.new(
              name: 'ids',
              types: [SchemaRegistry::PropertyType::Array],
              description: 'It fetches the ids of all goals',
              required: true,
              items: [prop]
            )
          ]
        )
      end

      xit do
        parameters = output['paths'].values.first['get']['parameters']

        expect(parameters.first['schema']).to have_key('items')
      end
    end

    context 'required parameters' do
      let(:verb_schema) do
        SchemaRegistry::Schema.new(
          name: 'employees',
          namespace: 'employees',
          properties: [
            SchemaRegistry::Property.new(
              name: 'id',
              types: [SchemaRegistry::PropertyType::Integer],
              description: 'It does something',
              required: true
            ),
            SchemaRegistry::Property.new(
              name: 'name',
              types: [SchemaRegistry::PropertyType::Null, SchemaRegistry::PropertyType::String],
              description: 'It does something',
              required: true
            )
          ]
        )
      end

      it do
        parameters = output['paths'].values.first['get']['parameters']

        expect(parameters.first['required']).to be_truthy
        expect(parameters.last['required']).to be_falsey
      end
    end

    context 'deprecated parameters' do
      around { |example| Timecop.freeze(current_date) { example.run } }

      let(:current_date) { Date.new(2022, 10, 28) }
      let(:deprecated_on) { Date.new(2022, 10, 28) }

      let(:verb_schema) do
        SchemaRegistry::Schema.new(
          name: 'employees',
          namespace: 'employees',
          properties: [
            SchemaRegistry::Property.new(
              name: 'id',
              types: [SchemaRegistry::PropertyType::Integer],
              deprecated_on: deprecated_on,
              required: true
            ),
            SchemaRegistry::Property.new(
              name: 'name',
              types: [SchemaRegistry::PropertyType::Null, SchemaRegistry::PropertyType::String],
              deprecated_on: deprecated_on,
              required: true
            )
          ]
        )
      end

      context 'deprecated_on date is nil' do
        let(:deprecated_on) { nil }

        it do
          parameters = output['paths'].values.first['get']['parameters']

          expect(parameters.last['deprecated']).to be_falsey
        end
      end

      context 'before expiration date' do
        let(:current_date) { Date.new(2022, 10, 28) }

        it do
          parameters = output['paths'].values.first['get']['parameters']

          expect(parameters.last['deprecated']).to be_falsey
        end
      end

      context 'after expiration date' do
        let(:current_date) { Date.new(2022, 10, 29) }

        it do
          parameters = output['paths'].values.first['get']['parameters']

          expect(parameters.last['deprecated']).to be_truthy
        end
      end
    end

    context 'private parameters' do
      let(:verb_schema) do
        SchemaRegistry::Schema.new(
          name: 'employees',
          namespace: 'employees',
          properties: [
            SchemaRegistry::Property.new(
              name: 'id',
              types: [SchemaRegistry::PropertyType::Integer],
              description: 'It does something',
              required: true
            ),
            SchemaRegistry::Property.new(
              name: 'private_field_name',
              types: [SchemaRegistry::PropertyType::String],
              description: 'It does something',
              required: true,
              serialization_groups: Set[:private]
            )
          ]
        )
      end

      it 'non-private fields are included' do
        parameters = output['paths'].values.first['get']['parameters']
        expect(parameters).to(be_any { |p| p['name'] == 'id' })
      end

      it 'private fields are excluded' do
        parameters = output['paths'].values.first['get']['parameters']
        expect(parameters).not_to(be_any { |p| p['name'] == 'private_field_name' })
      end
    end

    context 'private body fields' do
      let(:verb_schema) do
        SchemaRegistry::Schema.new(
          name: 'employees',
          namespace: 'employees',
          properties: [
            SchemaRegistry::Property.new(
              name: 'id',
              types: [SchemaRegistry::PropertyType::Integer],
              description: 'It does something',
              required: true
            ),
            SchemaRegistry::Property.new(
              name: 'private_field_name',
              types: [SchemaRegistry::PropertyType::String],
              description: 'It does something',
              required: true,
              serialization_groups: Set[:private]
            )
          ]
        )
      end

      let(:verbs) do
        {
          create:
            ResourceRegistry::Verb.new(id: :create, dto_raw: dummy_dto.to_s, schema: verb_schema)
        }
      end

      it 'non-private fields are included' do
        body = output['paths'].values.first['post']['requestBody']['content']['application/json']
        expect(body['schema']['properties'].keys).to include('id')
      end

      it 'private fields are excluded' do
        body = output['paths'].values.first['post']['requestBody']['content']['application/json']
        expect(body['schema']['properties'].keys).not_to include('private_field_name')
      end
    end

    context 'schema prop is nilable' do
      let(:schema) do
        SchemaRegistry::Schema.new(
          name: 'employees',
          namespace: 'employees',
          properties: [
            SchemaRegistry::Property.new(
              name: 'id',
              types: [SchemaRegistry::PropertyType::Integer],
              required: true
            ),
            SchemaRegistry::Property.new(
              name: 'dummy_property',
              types: [SchemaRegistry::PropertyType::Null, SchemaRegistry::PropertyType::String],
              required: true
            ),
            SchemaRegistry::Property.new(
              name: 'another_dummy_property',
              types: [SchemaRegistry::PropertyType::Integer, SchemaRegistry::PropertyType::Null],
              required: true
            )
          ],
          raw_json_schema: {
            'employees' => {
              'type' => 'object',
              'properties' => {
                'id' => {
                  'type' => 'integer'
                },
                'dummy_property' => {
                  'type' => %w[null string]
                },
                'another_dummy_property' => {
                  'type' => %w[integer null]
                }
              }
            }
          }
        )
      end

      it do
        schema = output['components']['schemas']['employees']

        expect(schema['required']).to eq(['id'])
        expect(schema['properties']).to include(
          'id' => include('type' => 'integer'),
          'dummy_property' => include('type' => 'string'),
          'another_dummy_property' => include('type' => 'integer')
        )
      end
    end

    context 'schema prop not is nilable' do
      let(:schema_properties) do
        [
          SchemaRegistry::Property.new(
            name: 'id',
            types: [SchemaRegistry::PropertyType::Integer],
            required: true
          ),
          SchemaRegistry::Property.new(
            name: 'dummy_property',
            types: [SchemaRegistry::PropertyType::String],
            required: true
          )
        ]
      end

      it do
        expect(output['components']['schemas']['employees']['required']).to include 'dummy_property'
      end
    end

    context 'schema prop is private' do
      let(:schema_properties) do
        [
          SchemaRegistry::Property.new(
            name: 'id',
            types: [SchemaRegistry::PropertyType::Integer],
            required: true
          ),
          SchemaRegistry::Property.new(
            name: 'dummy_property',
            types: [SchemaRegistry::PropertyType::String],
            required: true,
            serialization_groups: Set[:foo]
          ),
          SchemaRegistry::Property.new(
            name: 'private_property',
            types: [SchemaRegistry::PropertyType::String],
            required: true,
            serialization_groups: Set[:private]
          )
        ]
      end

      it 'non-private fields are included' do
        properties = output['components']['schemas']['employees']['properties']
        expect(properties).to be_key('id')
        expect(properties).to be_key('dummy_property')
      end

      it 'private fields are excluded' do
        properties = output['components']['schemas']['employees']['properties']
        expect(properties).not_to be_key('private_property')
      end
    end

    context 'schema has an example' do
      let(:schema_properties) do
        [
          SchemaRegistry::Property.new(
            name: 'dummy_property',
            types: [SchemaRegistry::PropertyType::String],
            example: 'I am a dummy example',
            required: true
          )
        ]
      end

      it 'has an example' do
        expect(output['components']['schemas']['employees']['example']).to eq [
             { 'dummy_property' => 'I am a dummy example' }
           ]
      end
    end

    context 'schema deprecated' do
      around { |example| Timecop.freeze(current_date) { example.run } }

      let(:current_date) { Date.new(2022, 10, 28) }
      let(:deprecated_on) { Date.new(2022, 10, 28) }

      let(:schema_properties) do
        [
          SchemaRegistry::Property.new(
            name: 'dummy_property',
            types: [SchemaRegistry::PropertyType::String],
            deprecated_on: deprecated_on,
            required: true
          )
        ]
      end

      context 'expiration date is nil' do
        let(:deprecated_on) { nil }

        it do
          expect(
            output['components']['schemas']['employees']['properties']['dummy_property'][
              'deprecated'
            ]
          ).to be_falsey
        end
      end

      context 'before expiration date' do
        let(:current_date) { Date.new(2022, 10, 28) }

        it do
          expect(
            output['components']['schemas']['employees']['properties']['dummy_property'][
              'deprecated'
            ]
          ).to be_falsey
        end
      end

      context 'after expiration date' do
        let(:current_date) { Date.new(2022, 10, 29) }

        it do
          expect(
            output['components']['schemas']['employees']['properties']['dummy_property'][
              'deprecated'
            ]
          ).to be_truthy
        end
      end
    end

    describe 'schema property enum' do
      it 'does not exist' do
        property = output.dig('components', 'schemas', 'employees', 'properties', 'foo')

        keys = property.keys
        expect(keys).to be_present
        expect(keys).not_to include('enum')
      end

      context 'with a property that has a enum' do
        let(:schema_properties) do
          [
            SchemaRegistry::Property.new(
              name: 'foo',
              types: [SchemaRegistry::PropertyType::String],
              required: true,
              enum_values: %w[one two]
            )
          ]
          it do
            property = output.dig('components', 'schemas', 'employees', 'properties', 'foo')

            expect(property['enum']).to eq(%w[one two])
          end
        end
      end
    end

    context 'verb has summary' do
      let(:verbs) do
        {
          read:
            ResourceRegistry::Verb.new(
              id: :read,
              dto_raw: dummy_dto.to_s,
              summary: 'Example summary',
              schema: verb_schema
            )
        }
      end

      it { expect(output['paths'].values.first['get']['summary']).to eq 'Example summary' }
    end

    context 'verb deprecated' do
      around { |example| Timecop.freeze(current_date) { example.run } }

      let(:current_date) { Date.new(2022, 10, 28) }
      let(:deprecated_on) { Date.new(2022, 10, 28) }

      let(:verbs) do
        {
          read:
            ResourceRegistry::Verb.new(
              id: :read,
              dto_raw: dummy_dto.to_s,
              deprecated_on: deprecated_on,
              schema: verb_schema
            )
        }
      end

      context 'deprecated on is nil' do
        let(:deprecated_on) { nil }

        it { expect(output['paths'].values.first['get']['deprecated']).to be_falsey }
      end

      context 'before expiration date' do
        let(:current_date) { Date.new(2022, 10, 28) }

        it { expect(output['paths'].values.first['get']['deprecated']).to be_falsey }
      end

      context 'after expiration date' do
        let(:current_date) { Date.new(2022, 10, 29) }

        it { expect(output['paths'].values.first['get']['deprecated']).to be_truthy }
      end
    end
  end
end
