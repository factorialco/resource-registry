# typed: true

module ResourceRegistry
  class RegistrySingleton
    extend T::Sig

    include Singleton
    include MonitorMixin

    sig { returns(ResourceRegistry::Registry) }
    def registry
      synchronize do
        resource_registry, = initialized
        @registry ||= resource_registry
      end
    end

    sig { returns(ResourceRegistry::OverridesLoader) }
    def overrides_loader
      synchronize do
        _, _, overrides_loader = initialized

        @overrides_loader ||= overrides_loader
      end
    end

    private

    sig do
      returns(
        [ResourceRegistry::Registry, SchemaRegistry::Registry, ResourceRegistry::OverridesLoader]
      )
    end
    def initialized
      @initialized ||= ResourceRegistry::Initializer.new.call
    end
  end
end
