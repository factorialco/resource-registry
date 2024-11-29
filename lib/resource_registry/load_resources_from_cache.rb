# typed: strict

module ResourceRegistry
  class LoadResourcesFromCache
    extend T::Sig

    sig { returns(T::Array[Resource]) }
    def call
      # We early return to being able to generate this file in development,
      # otherwise the script generating it fails
      unless File.exist?(Rails.root.join("resources.json"))
        puts "Cache not found. Skipping loading resources from cache. Consider running `bin/rails resource_registry:generate_cache`"

        return []
      end

      cache_path = Rails.root.join("resources.json")
      resources = JSON.load_file(cache_path)
      resources
        .map { |res_def| ResourceRegistry::Resource.load(res_def) }
        .sort_by(&:path)
    end
  end
end
