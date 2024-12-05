# typed: strict
# frozen_string_literal: true

require_relative "resource"
require_relative "capabilities/capability_config"

module ResourceRegistry
  class Registry
    extend T::Sig

    class UnableToFindResourceError < StandardError
    end

    class DuplicatedIdentifierError < StandardError
    end

    sig { params(resources: T::Array[Resource]).void }
    def initialize(resources:)
      if duplicated_identifier?(resources)
        raise DuplicatedIdentifierError,
              "You have a duplicated resource in a component. Check that you don't have more than one repository with the same name in a component."
      end

      @resources =
        T.let(
          resources.index_by { |res| res.identifier.to_s },
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
        repository_class:
          T::Class[ResourceRegistry::Repositories::Base[T.untyped]]
      ).returns(T.nilable(Resource))
    end
    def fetch_for_repository(repository_class)
      resources_by_raw_repository[repository_class.to_s]
    end

    alias find_for_repository fetch_for_repository

    sig { returns(T::Hash[String, Resource]) }
    def fetch_all
      resources
    end

    sig do
      params(capabilities: T::Class[Capabilities::CapabilityConfig]).returns(
        T::Array[Resource]
      )
    end
    def fetch_with_capabilities(*capabilities)
      # FIXME: This is a hack to avoid having to change the interface of the method
      capabilities_set = T.unsafe(capabilities).to_set(&:key)

      fetch_all.values.select do |resource|
        capabilities_set <= resource.capabilities.keys.to_set
      end
    end

    private

    sig { returns(T::Hash[String, Resource]) }
    attr_accessor :resources

    sig { returns(T::Hash[String, Resource]) }
    def resources_by_raw_repository
      @resources_by_raw_repository ||=
        T.let(
          resources.values.index_by(&:repository_raw),
          T.nilable(T::Hash[String, Resource])
        )
    end

    sig { params(resources: T::Array[Resource]).returns(T::Boolean) }
    def duplicated_identifier?(resources)
      resources.map(&:identifier).uniq.size != resources.size
    end
  end
end
