# typed: strict

module ResourceRegistry
  class EntityFinder
    extend T::Sig

    sig do
      params(
        repository: T.any(T.class_of(ResourceRegistry::Repositories::Base))
      ).returns(T.nilable(T.class_of(T::Struct)))
    end
    def self.call(repository:)
      repo_klass = repository.to_s.split('::').last
      entity_klass = repo_klass&.sub('Repository', '')&.singularize
      entity_klass_str =
        repository
        .to_s
        .sub('Repositories', 'Entities')
        .sub('Repository', '')
        .split('::')
        .tap(&:pop)
        .join('::')

      entity_klass_str << "::#{entity_klass}"

      entity_klass_str.safe_constantize
    end
  end
end
