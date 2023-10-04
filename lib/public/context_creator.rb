# typed: strict

module ResourceRegistry
  class ContextCreator
    extend T::Sig

    sig { params(data: Dtos::Context).returns(Repositories::ReadOutputContext) }
    def self.create_output_context(data)
      context =
        Repositories::ReadOutputContext.new(
          pagination_type: pagination_context(data),
          sort: sort_context(data),
          filter: data.filter_params
        )
      context.apply_after if context.filter&.any_in_memory
      context
    end

    sig do
      params(data: Dtos::Context).returns(T.nilable(Repositories::OutputContexts::PaginateCursor))
    end
    private_class_method def self.create_cursor_context(data)
      Repositories::OutputContexts::PaginateCursor.new(
        after_id: data.after_id,
        before_id: data.before_id,
        page_size: data.limit,
        direction: data.direction,
        sort: sort_context(data)
      )
    end

    sig { params(data: Dtos::Context).returns(T.nilable(Repositories::OutputContexts::Sort)) }
    private_class_method def self.sort_context(data)
      sort_params = data.sort_params
      return nil unless sort_params
      fields = sort_params.field.split
      ordering = fields.each_with_object({}) { |item, hash| hash[item.to_sym] = sort_params.order }
      Repositories::OutputContexts::Sort.new(ordering: ordering)
    end

    sig do
      params(data: Dtos::Context).returns(
        T.nilable(
          T.any(
            Repositories::OutputContexts::PaginateOffset,
            Repositories::OutputContexts::PaginateCursor
          )
        )
      )
    end
    def self.pagination_context(data)
      return nil if data.skip_pagination

      create_offset_context(data) || create_cursor_context(data)
    end

    sig do
      params(data: Dtos::Context).returns(T.nilable(Repositories::OutputContexts::PaginateOffset))
    end
    private_class_method def self.create_offset_context(data)
      return nil unless data.offset_page
      Repositories::OutputContexts::PaginateOffset.new(
        page: T.must(data.offset_page),
        page_size: data.limit
      )
    end
  end
end
