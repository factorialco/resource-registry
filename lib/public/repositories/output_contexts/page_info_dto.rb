# typed: strict

module ResourceRegistry
  module Repositories
    module OutputContexts
      class PageInfoDto < T::Struct
        const :has_next_page, T::Boolean, default: false
        const :has_previous_page, T::Boolean, default: false
        const :start_cursor, T.nilable(String), default: nil
        const :end_cursor, T.nilable(String), default: nil
      end
    end
  end
end
