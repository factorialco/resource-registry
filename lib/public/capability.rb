# typed: strict

module ResourceRegistry
  # This class enumerates features that are available to a resource. Each
  # resource knows which subset of these it needs to be used with.
  class Capability < T::Enum
    extend T::Sig
    enums do
      Graphql = new(:graphql) # Exposes the resource through the Graphql API
      Reports = new(:reports) # Exposes the resource through the Reports feature (SQL "API")
      Rest = new(:rest) # Exposes the resource through the REST API
      PowerBi = new(:power_bi) # Exposes the resource through the PowerBi endpoint
      AutogeneratePermissions = new(:autogenerate_permissions) # Autogenerates Permissions for the resource
    end

    sig { params(data: T::Hash[String, T.untyped]).returns(Capabilities::CapabilityConfig) }
    def self.load(data)
      key = data['key']
      case key.to_sym
      when :graphql
        Capabilities::Graphql.new(
          included_in_root_query: !data['included_in_root_query'].to_s.casecmp('false').zero?
        )
      when :reports
        Capabilities::Reports.new(data.symbolize_keys.except(:key))
      when :rest
        Capabilities::Rest.new(is_public: !!data['is_public'])
      when :power_bi
        Capabilities::PowerBi.new
      when :autogenerate_permissions
        Capabilities::AutogeneratePermissions.new
      else
        raise ArgumentError, "unknown capability #{key}"
      end
    end

    sig { params(capability: Capabilities::CapabilityConfig).returns(T::Hash[String, T.untyped]) }
    def self.dump(capability)
      { 'key' => capability.key }.merge!(capability.serialize)
    end
  end
end
