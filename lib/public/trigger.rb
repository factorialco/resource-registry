# typed: true
module ResourceRegistry
  class Trigger
    class Data < T::Struct
      const :resource, String
      const :id, Integer
    end

    extend T::Sig

    sig { params(resource_identifier: String).void }
    def initialize(resource_identifier)
      @resource_identifier = resource_identifier
    end

    sig { params(company_id: Integer, id: Integer).returns(T::Boolean) }
    def created(company_id, id)
      trigger(:created, company_id, id)
    end

    sig { params(company_id: Integer, id: Integer).returns(T::Boolean) }
    def updated(company_id, id)
      trigger(:updated, company_id, id, id: id)
    end

    sig { params(company_id: Integer, id: Integer).returns(T::Boolean) }
    def deleted(company_id, id)
      trigger(:deleted, company_id, id, id: id)
    end

    private

    sig do
      params(
        event: Symbol,
        company_id: Integer,
        id: Integer,
        arguments: T::Hash[String, T.untyped]
      ).returns(T::Boolean)
    end
    def trigger(event, company_id, id, arguments = {})
      company = Company.find(company_id)

      return false unless company&.feature_enabled?(Features::Catalog::DEV_REALTIME_ENGINE)

      resource = Rails.configuration.resource_registry.fetch(@resource_identifier)

      return false unless resource

      field_name = "#{resource.namespace}_#{resource.name}_#{event}"

      Rails.application.config.graphql_schema.subscriptions.trigger field_name,
                             arguments,
                             { resource: resource.identifier.to_s, id: id },
                             scope: company_id
      true
    end
  end
end
