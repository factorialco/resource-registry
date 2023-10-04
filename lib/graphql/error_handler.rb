# typed: strict

module ResourceRegistry
  module Graphql
    class ErrorHandler
      extend T::Sig

      sig { params(type: Outcome::ErrorType).returns(String) }
      def self.message_for(type)
        case type
        when Outcome::ErrorType::Forbidden
          I18n.t('api_exceptions.handler.forbidden_access')
        when Outcome::ErrorType::MalformedRequest
          I18n.t('api_exceptions.handler.malformed_response')
        when Outcome::ErrorType::MissingResource
          I18n.t('api_exceptions.handler.not_found')
        when Outcome::ErrorType::PaymentRequired
          I18n.t('api_exceptions.handler.payment_required')
        when Outcome::ErrorType::ValidationFailed
          I18n.t('api_exceptions.handler.statement_invalid')
        when Outcome::ErrorType::ServiceUnreachable
          I18n.t('api_exceptions.handler.service_unreachable')
        when Outcome::ErrorType::Unauthorized
          I18n.t('api_exceptions.handler.unauthorized')
        when Outcome::ErrorType::MalformedResource
          I18n.t('api_exceptions.handler.malformed_response')
        when Outcome::ErrorType::InvalidState
          I18n.t('api_exceptions.handler.invalid_state')
        when Outcome::ErrorType::Default
          I18n.t('api_exceptions.handler.unknown_error')
        else
          T.absurd(type)
        end
      end
    end
  end
end
