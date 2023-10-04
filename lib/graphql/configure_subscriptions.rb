# typed: true

module ResourceRegistry
  module Graphql
    class ConfigureSubscriptions
      extend T::Sig

      sig { returns(Resource) }
      attr_reader :resource

      sig { returns(T.class_of(BaseObject)) }
      attr_reader :root_subscription

      sig { returns(T.class_of(BaseObject)) }
      attr_reader :type

      sig do
        params(
          resolved_types: T::Hash[String, T.untyped],
          resource: Resource,
          root_subscription: T.class_of(BaseObject),
          type: T.class_of(BaseObject)
        ).void
      end
      def initialize(resolved_types, resource, root_subscription, type)
        @resolved_types = resolved_types
        @resource = resource
        @root_subscription = root_subscription
        @type = type
      end

      sig { void }
      def call
        configure_deleted

        return unless resource.verbs[:read]&.dto&.decorator&.props&.to_h&.key?(:ids)

        configure_created
        configure_updated
      end

      private

      sig { void }
      def configure_created
        subscription = create_subscription_type(resource.name, :created)
        subscription.field resource.name, type, null: true

        field_name = "#{resource.namespace}_#{resource.name}_created"
        root_subscription.field field_name, subscription: subscription

        subscription.define_method(:update) do
          ResourceRegistry::Graphql::ConfigureSubscriptions.payload_for(
            T.unsafe(self).context[:policy_context],
            ResourceRegistry::Trigger::Data.new(T.unsafe(self).object)
          )
        end
      end

      sig { void }
      def configure_deleted
        subscription = create_subscription_type(resource.name, :deleted)
        subscription.field :id, GraphQL::Types::ID, null: true

        field_name = "#{resource.namespace}_#{resource.name}_deleted"
        root_subscription.field field_name, subscription: subscription do
          argument :id, GraphQL::Types::ID, required: false
        end

        subscription.define_method(:update) do |*_args|
          object_struct = ResourceRegistry::Trigger::Data.new(T.unsafe(self).object)
          { id: object_struct.id }
        end
      end

      sig { void }
      def configure_updated
        subscription = create_subscription_type(resource.name, :updated)
        subscription.field resource.name, type, null: true

        field_name = "#{resource.namespace}_#{resource.name}_updated"
        root_subscription.field field_name, subscription: subscription do
          argument :id, GraphQL::Types::ID, required: false
        end

        subscription.define_method(:update) do |*_args|
          ResourceRegistry::Graphql::ConfigureSubscriptions.payload_for(
            T.unsafe(self).context[:policy_context],
            ResourceRegistry::Trigger::Data.new(T.unsafe(self).object)
          )
        end
      end

      sig { params(name: Symbol, event_name: Symbol).returns(T.class_of(BaseSubscription)) }
      def create_subscription_type(name, event_name)
        subscription = Class.new(BaseSubscription)

        subscription.graphql_name("#{resource.namespace}_#{name}_#{event_name}_subscription")
        subscription.subscription_scope :company_id
        subscription
      end

      class << self
        extend T::Sig

        sig do
          params(policy_context: T.untyped, object: T.untyped).returns(
            T.nilable(T.any(Symbol, T::Hash[String, T.untyped]))
          )
        end
        def payload_for(policy_context, object)
          resource = Rails.configuration.resource_registry.fetch(object.resource.to_s)

          return unless resource

          read_verb = resource.verbs[:read]
          return unless read_verb

          id = object.id

          repository = resource.repository.new(policy_context: policy_context)

          raw_result =
            case repository
            when ::Repositories::BaseOld
              repository.read(dto: read_verb.dto.new(ids: [id])).unwrap!.first
            when ::Repositories::Base
              repository.read(dto: read_verb.dto.new(ids: [id])).entities.unwrap!.first
            end

          return GraphQL::Schema::Subscription::NO_UPDATE unless raw_result

          { "#{resource.name}": repository.serialize(entity: raw_result).with_indifferent_access }
        end
      end
    end
  end
end
