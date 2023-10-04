# typed: true

module ResourceRegistry
  class SchemaGenerator
    extend T::Sig

    Repository =
      T.type_alias { T.any(T.class_of(Repositories::Base), T.class_of(Repositories::BaseOld)) }

    sig { params(repository: Repository).returns(T.nilable(SchemaRegistry::Schema)) }
    def generate(repository:)
      struct_klass = ResourceRegistry::EntityFinder.call(repository: repository)
      return nil unless struct_klass

      definition = SchemaRegistry::GenerateFromStruct.new(struct_klass: struct_klass).call
      SchemaRegistry::JsonSchemaMapper.new(
        namespace: repository.namespace,
        definition: definition
      ).call
    end

    private

    sig { params(repo: Repository).returns(Symbol) }
    def identifier_from_repo(repo)
      "#{repo.namespace.underscore}.#{T.must(repo.name).underscore.singularize}".to_sym
    end
  end
end
