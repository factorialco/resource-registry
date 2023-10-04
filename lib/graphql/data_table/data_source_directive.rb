# typed: strict

module ResourceRegistry
  module Graphql
    module DataTable
      class DataSourceDirective < GraphQL::Schema::Directive
        graphql_name 'dataSource'
        locations(FIELD_DEFINITION, FIELD)
        argument :format, String, required: false
        argument :file_name, String, required: false
        argument :projections, [ProjectionType], required: false
        description 'The data source directive.'
      end
    end
  end
end
