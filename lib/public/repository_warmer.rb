# typed: false

# The criteria for considering something as a resource in the Resource
# Registry is dictated by the presence of its repository which has
# a specific ancestor.
# This class effectively eager loads repositories which is needed when
# assessing the code to generate a schematic view of the state of resources
class RepositoryWarmer
  extend T::Sig

  sig { void }
  def call # rubocop:disable Metrics/AbcSize
    repository_constants =
      ::Rails::Engine
      .subclasses
      .map(&:instance)
      .filter { |instance| instance.paths.path.dirname.to_s.include?('components') }
      .flat_map do |instance|
        pathname = instance.paths.path
        namespace = instance.railtie_namespace.to_s.underscore
        path_base =
          File.join(
            pathname.dirname,
            pathname.basename,
            'app',
            'public',
            namespace,
            'repositories'
          )
        path = File.join(path_base, '**', '*.rb')
        files = Dir[path]

        files.map do |file|
          klassname = file.sub(path_base, '').sub('.rb', '').split('/').map(&:camelize).join('::')

          "#{namespace.camelize}::Repositories#{klassname}"
        end
      end

    repository_constants.sort.each(&:constantize)
  end
end
