# typed: true

module ResourceRegistry
  module Graphql
    class FileType < GraphQL::Schema::Scalar
      description 'A file to be uploaded'

      # ApolloUploadServer returns a ApolloUploadServer::Wrappers::UploadedFile
      # object, which is a subclass of ActionDispatch::Http::UploadedFile (the
      # base class for all uploaded files).
      def self.coerce_input(file, _context)
        ActionDispatch::Http::UploadedFile.new(
          filename: file.original_filename,
          type: file.content_type,
          headers: file.headers,
          tempfile: file.tempfile
        )
      end
    end
  end
end
