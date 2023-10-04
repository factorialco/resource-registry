# typed: true

module ResourceRegistry
  module Graphql
    class BaseSchema < GraphQL::Schema
      introspection(Introspection)
      instrument(:query, ContextApplierInstrumentation)

      # FIXME: This exception should not be in ApiPublic namespace
      rescue_from(ApiPublic::Authentication::InvalidState) do |_err, _obj, _args, _ctx, _field|
        Telemetry::Tracer.keep_trace
        raise GraphQL::ExecutionError,
              I18n.t(
                'activerecord.errors.models.api_public.authentication.attributes.invalid_state'
              )
      end

      rescue_from(Outcome::UnwrapError) do |err|
        Telemetry::Tracer.keep_trace
        raise GraphQL::ExecutionError, err.error.to_s
      end
    end
  end
end
