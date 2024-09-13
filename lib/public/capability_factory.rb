# typed: strict

module ResourceRegistry
  # This class enumerates features that are available to a resource. Each
  # resource knows which subset of these it needs to be used with.
  class CapabilityFactory
    extend T::Sig

    sig do
      params(
        data: T::Hash[String, T.untyped],
        capabilities: T::Hash[Symbol, T.all(T::Class[Capabilities::CapabilityConfig], T.class_of(T::Struct))]
      ).returns(Capabilities::CapabilityConfig)
    end
    def self.load(data, capabilities: ResourceRegistry.configuration.capabilities)
      key = data['key']
      capability = capabilities.fetch(key.to_sym)
      # FIXME: This T.let should not be needed
      T.let(capability, T.class_of(T::Struct)).from_hash(data)
    end

    sig { params(capability: Capabilities::CapabilityConfig).returns(T::Hash[String, T.untyped]) }
    def self.dump(capability)
      { 'key' => capability.class.key }.merge!(capability.serialize)
    end
  end
end
