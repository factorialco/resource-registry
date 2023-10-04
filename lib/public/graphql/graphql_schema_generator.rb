# rubocop:disable Metrics/ParameterLists, Metrics/AbcSize
# typed: strict

module ResourceRegistry
  module Graphql
    class GraphqlSchemaGenerator
      extend T::Sig

      class RelationshipResourceNotFound < StandardError
      end

      sig { params(resources: T::Array[Resource]).void }
      def initialize(resources:)
        @resources = resources
      end

      sig { returns(T.class_of(GraphQL::Schema)) }
      def call
        schema_definition
      end

      sig { returns(String) }
      def to_s
        GraphQL::Schema::Printer.print_schema(schema_definition)
      end

      private

      sig { returns(T::Array[Resource]) }
      attr_reader :resources

      sig { returns(T.class_of(GraphQL::Schema)) }
      def schema_definition # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        graphql_schema = Class.new(BaseSchema)
        graphql_schema.use(GraphQL::Dataloader)
        graphql_schema.use(GraphQL::Subscriptions::ActionCableSubscriptions)
        graphql_schema.max_complexity 200

        query = create_root_type('query')
        mutation = create_root_type('mutation')
        subscription = create_root_type('subscription')

        resources_by_domain = resources.group_by(&:namespace)

        resource_types = {}
        resolved_types = {}

        resources_by_domain.keys.each do |domain| # rubocop:disable Metrics/BlockLength
          domain_path = domain.camelize(:lower)
          mutations_domain_path = "#{domain.camelize(:lower)}Mutations"

          domain_obj = Class.new(BaseObject)
          domain_obj.graphql_name(domain_path)

          domain_mutation = Class.new(BaseObject)
          domain_mutation.graphql_name(mutations_domain_path)

          resources_by_domain[domain]&.each do |resource|
            resource_types[resource.identifier] = configure_resource(
              resolved_types,
              resource,
              domain_obj,
              domain_mutation,
              subscription
            ),
            resource
          end

          if domain_obj.fields.any?
            query.field(
              domain_path,
              type: domain_obj,
              directives: {
                NamespaceDirective => {
                }
              },
              null: false
            )
            query.define_method(domain_path) do
              {} # Placeholder response for nesting namespaces
            end
          end

          if domain_mutation.fields.any? # rubocop:disable Style/Next
            mutation.field(mutations_domain_path, type: domain_mutation, null: false)
            mutation.define_method(mutations_domain_path) do
              {} # Placeholder response for nesting namespaces
            end
          end
        end

        # A second iteration to configure the relationships. We need all the
        # resources to be defined before setting relationships
        resources.each do |resource|
          configure_relationships(resource, resource_types, resolved_types)
        end

        graphql_schema.query(query)
        graphql_schema.mutation(mutation)
        graphql_schema.subscription(subscription)

        DatadogWrapper.run { graphql_schema.use(CustomDataDogTracing) }

        graphql_schema
      end

      sig { params(name: String).returns(T.class_of(BaseObject)) }
      def create_root_type(name)
        root_type = Class.new(BaseObject)
        root_type.graphql_name("root_#{name}")
        root_type.description("Root #{name}")
        root_type
      end

      sig do
        params(
          resolved_types: T::Hash[String, T.untyped],
          resource: Resource,
          domain_obj: T.class_of(BaseObject),
          mutation: T.class_of(BaseObject),
          subscription: T.class_of(BaseObject)
        ).returns(T.class_of(BaseObject))
      end
      def configure_resource(resolved_types, resource, domain_obj, mutation, subscription)
        type = create_type_from_resource(resource)
        resource.schema.properties.each do |property|
          attributes = { null: property.nilable?, complexity: 1 }
          property_is_key_of_relationship =
            resource.relationships.values.any? do |relationship|
              relationship.field.to_s == property.name
            end

          if property.name.end_with?('_id', '_ids') && property_is_key_of_relationship
            attributes[
              :deprecation_reason
            ] = "This kind of 'foreign key' is not used in GraphQL. Use the relation"
          end

          resolved_field =
            SchemaFieldResolver.new(resolved_types).call(property, resource.collection_name)
          field = type.field(resolved_field.name, resolved_field.type, **attributes)
          field.directive(ResolvableDirective) if property.resolvable
        end

        capability = T.cast(resource.capability!(Capability::Graphql), Capabilities::Graphql)

        if capability.included_in_root_query
          ConfigureReadQueries.new(resolved_types, resource, domain_obj, type).call
          ConfigureMutations.new(resolved_types, resource, mutation, type).call
          ConfigureSubscriptions.new(resolved_types, resource, subscription, type).call
        end

        type
      end

      sig { params(resource: Resource).returns(T.class_of(BaseObject)) }
      def create_type_from_resource(resource)
        type = Class.new(BaseObject)
        type.graphql_name(resource.camelize)
        type.description(resource.description)
        type
      end

      sig do
        params(
          resource: Resource,
          resource_types: T::Hash[Symbol, [T.class_of(BaseObject), Resource]],
          resolved_types: T::Hash[String, T.untyped]
        ).void
      end
      def configure_relationships(resource, resource_types, resolved_types)
        type, = resource_types[resource.identifier]

        resource.relationships.each do |rel_name, rel|
          field_type, res = resource_types[rel.resource_id]

          unless field_type
            raise RelationshipResourceNotFound,
                  "Relationship object not found for #{rel.resource_id}"
          end

          upsert_field(rel, rel_name, type, field_type, res, resolved_types)
          define_method(type, rel_name.to_s, rel, res)
        end

        type
      end

      sig do
        params(
          read_verb: ResourceRegistry::Verb,
          resolved_types: T::Hash[String, T.untyped],
          resource: ResourceRegistry::Resource,
          rel: ResourceRegistry::Relationship,
          fields: T::Array[GraphQL::Schema::Field]
        ).returns(T.untyped)
      end
      def add_arguments(read_verb, resolved_types, resource, rel, fields)
        read_schema = read_verb.schema
        read_schema.properties.each do |property|
          argument =
            SchemaArgumentResolver.new(resolved_types).call(
              property,
              resource.collection_name,
              read_verb.id
            )

          next if skip_argument?(rel, argument)

          fields.each do |field|
            if property.default.nil?
              T.unsafe(field).argument(argument.name, argument.type, required: argument.required)
            else
              T.unsafe(field).argument(
                argument.name,
                argument.type,
                required: argument.required,
                default_value: property.default
              )
            end
          end
        end
      end

      # We provide this in the dataloader
      sig do
        params(rel: ResourceRegistry::Relationship, argument: SchemaArgument).returns(T::Boolean)
      end
      def skip_argument?(rel, argument)
        return true if rel.fixed_dto_params&.key?(argument.name)

        case rel.type
        when ResourceRegistry::Relationship::Type::BelongsTo,
             ResourceRegistry::Relationship::Type::HasManyThrough
          argument.name == rel.primary_key.to_s.pluralize
        when ResourceRegistry::Relationship::Type::HasOne,
             ResourceRegistry::Relationship::Type::HasMany
          argument.name == rel.field.to_s.pluralize
        end
      end

      sig do
        params(
          rel: ResourceRegistry::Relationship,
          rel_name: Symbol,
          type: T.untyped,
          field_type: T.nilable(T.class_of(BaseObject)),
          resource: T.nilable(Resource),
          resolved_types: T::Hash[String, T.untyped]
        ).returns(GraphQL::Schema::Field)
      end
      def upsert_field(rel, rel_name, type, field_type, resource, resolved_types)
        connection_field = nil
        single_field =
          case rel.type
          when ResourceRegistry::Relationship::Type::HasMany,
               ResourceRegistry::Relationship::Type::HasManyThrough
            connection_field = define_connection_field(rel_name, type, field_type)
            define_method(type, "#{rel_name}_connection", rel, resource, connection: true)

            GraphQL::Schema::Field.new(
              name: rel_name,
              type: [field_type],
              null: false,
              complexity: 10
            )
          when ResourceRegistry::Relationship::Type::HasOne,
               ResourceRegistry::Relationship::Type::BelongsTo
            GraphQL::Schema::Field.new(
              name: rel_name,
              type: field_type,
              null: rel.optional,
              complexity: 5
            )
          end

        res_verbs = resource&.verbs
        if res_verbs
          add_arguments(
            T.must(res_verbs[:read]),
            resolved_types,
            resource,
            rel,
            [single_field, connection_field].compact
          )
        end

        if type.own_fields.include?(rel_name.to_s)
          override_message = 'Warning: this relationship is currently overriding an entity field'
          if single_field.description
            single_field.description("#{single_field.description}. #{override_message}")
          else
            single_field.description(override_message)
          end
        end

        type.own_fields[single_field.name] = single_field
        single_field
      end

      sig do
        params(
          rel_name: Symbol,
          type: T.untyped,
          field_type: T.nilable(T.class_of(BaseObject))
        ).returns(GraphQL::Schema::Field)
      end
      def define_connection_field(rel_name, type, field_type)
        field_type&.connection_type_class(CustomConnection)
        field_type&.edge_type_class(CustomEdge)
        type.field(
          "#{rel_name}_connection",
          T.must(field_type).connection_type,
          directives: {
            ConnectionDirective => {
            }
          },
          null: false,
          complexity: 10,
          connection: true,
          extras: [:lookahead]
        )
      end

      sig do
        params(
          type: T.untyped,
          rel_name: String,
          rel: Relationship,
          res: T.nilable(Resource),
          connection: T::Boolean
        ).returns(T.untyped)
      end
      def define_method(type, rel_name, rel, res, connection: false)
        type.define_method(rel_name) do |lookahead: nil, **kwargs|
          # Hack to access class methods needed in this annonymous method
          inst = T.cast(self, BaseObject)
          inst.context[:skip_pagination] = lookahead&.selects?(:total_count) if connection

          attribute =
            case rel.type
            when ResourceRegistry::Relationship::Type::HasOne,
                 ResourceRegistry::Relationship::Type::HasMany
              rel.primary_key
            when ResourceRegistry::Relationship::Type::BelongsTo,
                 ResourceRegistry::Relationship::Type::HasManyThrough
              rel.field
            end

          resource_id = inst.object[attribute.to_s]

          inst
            .dataloader
            .with(
              ResourceRegistry::Graphql::GraphqlRepositorySource,
              res,
              inst.context,
              rel,
              kwargs,
              connection: connection
            )
            .load(resource_id)
        end
      end
    end
  end
end

# rubocop:enable Metrics/ParameterLists, Metrics/AbcSize
