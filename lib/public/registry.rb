# typed: strict

module ResourceRegistry
  class Registry
    extend T::Sig

    class UnableToFindResourceError < StandardError
    end

    sig { params(resources: T::Array[Resource]).void }
    def initialize(resources:)
      @resources =
        T.let(
          resources.each_with_object({}) { |res, memo| memo[res.identifier.to_s] = res },
          T::Hash[String, Resource]
        )
    end

    sig { params(identifier: String).returns(T.nilable(Resource)) }
    def fetch(identifier)
      resources[identifier]
    end

    sig { params(identifier: String).returns(Resource) }
    def fetch!(identifier)
      resource = fetch(identifier)

      return resource if resource.present?

      raise UnableToFindResourceError, "#{identifier} does not exist"
    end

    sig do
      params(
        repository_class: T.any(T.class_of(Repositories::Base), T.class_of(Repositories::BaseOld))
      ).returns(T.nilable(Resource))
    end
    def fetch_for_repository(repository_class)
      fetch_all.values.find { |r| r.repository == repository_class }
    end

    sig { returns(T::Hash[String, Resource]) }
    def fetch_all
      resources
    end

    sig { params(capabilities: Capability).returns(T::Array[Resource]) }
    def fetch_with_capabilities(*capabilities)
      capabilities_set = capabilities.to_set(&:serialize)
      fetch_all.values.select { |resource| capabilities_set <= resource.capabilities.keys.to_set }
    end

    sig { returns(T::Array[Resource]) }
    def fetch_with_any_trait
      fetch_all.values.select { |resource| resource.traits.any? { |_k, v| v.present? } }
    end

    sig do
      params(
        repository: T.any(T.class_of(::Repositories::Base), T.class_of(::Repositories::BaseOld))
      ).returns(T.nilable(Resource))
    end
    def find_by_repository(repository)
      fetch_all.values.find { |resource| resource.repository == repository }
    end

    private

    sig { returns(T::Hash[String, Resource]) }
    attr_accessor :resources
  end
end
