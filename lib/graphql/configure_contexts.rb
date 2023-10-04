# typed: strict

module ResourceRegistry
  module Graphql
    class ConfigureContexts
      extend T::Sig

      SORT = T.let('sort_order'.freeze, String)

      sig do
        params(
          resolved_types: T::Hash[String, T.untyped],
          query: T.class_of(BaseObject),
          type: T.class_of(BaseObject),
          resource: Resource,
          read_verb: ResourceRegistry::Verb
        ).returns(T.untyped)
      end
      def self.create_context_connection(resolved_types:, query:, type:, resource:, read_verb:)
        type.connection_type_class(CustomConnection)
        type.edge_type_class(CustomEdge)
        query.field(
          "#{resource.collection_name}_connection",
          type.connection_type,
          connection: true,
          null: false,
          directives: {
            ConnectionDirective => {
            }
          },
          extras: [:ast_node]
        ) do |f|
          T.unsafe(f).directive(DataTable::DataSourceDirective)
          read_verb.schema.properties.each do |property|
            argument =
              SchemaArgumentResolver.new(resolved_types).call(property, resource.collection_name)

            if property.default.nil?
              T.unsafe(f).argument(argument.name, argument.type, required: argument.required)
            else
              T.unsafe(f).argument(
                argument.name,
                argument.type,
                required: argument.required,
                default_value: property.default
              )
            end
          end
          ConfigureContexts.create_arguments(f, resource)
        end
        ConfigureContexts.create_connection_method(
          query: query,
          resource: resource,
          read_dto: read_verb.dto
        )
      end

      sig do
        params(
          query: T.class_of(BaseObject),
          resource: Resource,
          read_dto: T.class_of(T::Struct)
        ).returns(T.untyped)
      end
      def self.create_connection_method(query:, resource:, read_dto:)
        query.define_method("#{resource.collection_name}_connection") do |**kwargs|
          inst = T.cast(self, BaseObject)
          policy_context = inst.context[:policy_context]
          repository = resource.repository.new(policy_context: policy_context)

          data = ActionController::Parameters.new(kwargs)
          dto =
            ConfigureContexts.create_dto(
              read_dto,
              kwargs.extract!(*read_dto.decorator.props.to_h.keys)
            )

          case repository
          when ::Repositories::BaseOld
            raise NotImplementedError, 'Connections are not implemented for BaseOld repositories'
          when ::Repositories::Base
            ContextConnection.new(
              repository: repository,
              dto: dto,
              data: data,
              schema: resource.schema,
              inst_context: inst.context
            )
          end
        end
      end

      sig { params(field: T.nilable(GraphQL::Schema::Field), resource: Resource).void }
      def self.create_arguments(field, resource)
        T.unsafe(field).argument('offset_page', Integer, required: false)
        T.unsafe(field).argument(SORT, SortType, required: false)
        FilterConfiguration.create_arguments(field, resource)
      end

      sig { params(dto: T.class_of(T::Struct), kwargs: T.untyped).returns(T::Struct) }
      def self.create_dto(dto, kwargs)
        ResourceStructBuilder.new(dto).build(kwargs)
      end
    end
  end
end
