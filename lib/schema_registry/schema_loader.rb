# typed: strict

module SchemaRegistry
  class SchemaLoader
    extend T::Sig

    sig { params(schema_registry: Registry).void }
    def initialize(schema_registry:)
      @schema_registry = schema_registry
    end

    sig { params(paths: T::Array[[String, String]]).void }
    def load(paths)
      # for each schema folder loads all the schemas defined in
      # YAML
      paths.each do |namespace, path|
        schemas = load_path_files(namespace, path)

        schemas.each { |schema| schema_registry.register(schema) }
      end
    end

    private

    sig { returns(SchemaRegistry::Registry) }
    attr_reader :schema_registry

    sig do
      params(namespace: String, path: String).returns(
        T::Array[SchemaRegistry::Schema]
      )
    end
    def load_path_files(namespace, path)
      # TODO: Maybe load graphql schemas too?
      # TODO: Support yml extension too
      files = Dir[File.join(path, "*.yaml")]

      processed_schemas =
        files.map do |file|
          fcontent = File.open(file)

          # TODO: Support graphql files
          # TODO: Add validation of schemas
          YAML.safe_load(fcontent.read)
        end

      processed_schemas.map do |processed|
        JsonSchemaMapper.new(namespace: namespace, definition: processed).call
      end
    end
  end
end
