# typed: strict

module ResourceRegistry
  module Dtos
    class Context < T::Struct
      const :offset_page, T.nilable(Integer)
      const :limit, Integer
      const :after_id, T.nilable(String)
      const :before_id, T.nilable(String)
      const :direction, Symbol, default: :forward
      const :skip_pagination, T::Boolean, default: false
      const :sort_params, T.nilable(Sort)
      const :filter_params, T.nilable(Repositories::OutputContexts::Filter)
    end
  end
end
