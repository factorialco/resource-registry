# typed: strict

module ResourceRegistry
  module Graphql
    module DataTable
      class ProjectionType < GraphQL::Schema::InputObject
        description 'Projections needed to build a table - column names and paths'
        argument :title, String, 'Title of the column'
        argument :path,
                 String,
                 'The path to the field that should be in this column',
                 required: false
        argument :template, String, 'The export tamplate, in Liquid format', required: false
      end
    end
  end
end
