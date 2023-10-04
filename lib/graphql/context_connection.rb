# typed: true

module ResourceRegistry
  module Graphql
    class ContextConnection < GraphQL::Pagination::Connection
      extend T::Sig
      MAX_PAGE_SIZE = 100

      class OffsetDto < T::Struct
        const :offset_page, T.nilable(Integer)
      end

      class SortOrder < T::Struct
        const :sort_order, T.nilable(SortType)
      end

      sig do
        params(
          repository: Repositories::Base[T.untyped],
          dto: T::Struct,
          schema: SchemaRegistry::Schema,
          inst_context: T.nilable(GraphQL::Query::Context),
          data: ActionController::Parameters
        ).void
      end
      def initialize(
        repository:,
        dto:,
        schema:,
        inst_context:,
        data: ActionController::Parameters.new
      )
        super []
        @dto = dto
        @data = data
        @repository = repository
        @skip_pagination = inst_context ? inst_context[:skip_pagination] : false
        @schema = schema
        @inst_context = inst_context
      end

      sig { returns(T::Array[T.untyped]) }
      def nodes
        result.map { |res| @repository.serialize(entity: res).with_indifferent_access }
      end

      sig { params(item: T::Hash[Symbol, T.untyped]).returns(String) }
      def cursor_for(item)
        Repositories::BaseEncoder.encode(item[:id].to_s)
      end

      sig { returns(T.nilable(Repositories::OutputContexts::PageInfoDto)) }
      def page_info
        read_result.page_info
      end

      sig { returns(T.nilable(Integer)) }
      def total
        read_result.total_count
      end

      # @context.keyword_arguments[:first]

      sig { returns(T::Array[T.untyped]) }
      def result
        ResourceRegistry::Tracer.trace_repository(repository, verb: 'read', collection: true) do
          read_result.entities.unwrap!
        end
      end

      private

      sig { returns(ActionController::Parameters) }
      attr_reader :data

      sig { returns(T::Struct) }
      attr_reader :dto

      sig { returns(Repositories::Base[T.untyped]) }
      attr_reader :repository

      sig { returns(T::Boolean) }
      attr_reader :skip_pagination

      sig { returns(T.nilable(GraphQL::Query::Context)) }
      attr_reader :inst_context

      sig { returns(SchemaRegistry::Schema) }
      attr_reader :schema

      sig { returns(Integer) }
      def page_size
        value =
          case direction
          when :forward
            @first_value
          when :backward
            @last_value
          end

        return MAX_PAGE_SIZE unless value

        [value, MAX_PAGE_SIZE].min
      end

      sig { returns(Symbol) }
      def direction
        return :backward if @before_value.present? || @last_value.present?

        :forward
      end

      sig { returns(T.nilable(Dtos::Sort)) }
      def sort_dto
        sort_order = TypedParams[SortOrder].new.extract!(data).sort_order

        return nil unless sort_order

        field = schema.get_resolver_value(sort_order[:field].underscore)

        Dtos::Sort.new(field: T.must(field), order: sort_order[:order].to_sym)
      end

      sig { returns(Repositories::ReadOutputContext) }
      def context_data
        @context_data ||=
          begin
            offset_dto = TypedParams[OffsetDto].new.extract!(data)
            context_data =
              Dtos::Context.new(
                limit: page_size,
                offset_page: offset_dto.offset_page,
                sort_params: sort_dto,
                filter_params: FilterConfiguration.filter_dto(data, schema),
                after_id: after_id,
                before_id: before_id,
                direction: direction,
                skip_pagination: skip_pagination
              )
            output_context = ContextCreator.create_output_context(context_data)
            T.must(inst_context)[:in_memory_context] = output_context if inst_context
            output_context
          end
      end

      sig { returns(Repositories::ReadResult[T.untyped]) }
      def read_result
        @read_result ||= repository.read(dto: dto, context: context_data)
      end

      sig { returns(T.nilable(String)) }
      def after_id
        return nil unless @after_value
        decode_value(@after_value)
      end

      sig { returns(T.nilable(String)) }
      def before_id
        return nil unless @before_value
        decode_value(@before_value)
      end

      sig { returns(T.nilable(T::Boolean)) }
      def cursor_type_pagination?
        context_data.pagination_type&.cursor_type?
      end

      sig { params(value: String).returns(String) }
      def decode_value(value)
        Repositories::BaseEncoder.decode(value)
      end
    end
  end
end
