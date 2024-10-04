# typed: false

module ResourceRegistry
  class OverridesLoader
    extend T::Sig

    sig { returns(T::Array[T::Hash[String, T.untyped]]) }
    def overrides
      return [] unless defined?(::Rails)

      @overrides ||=
        T.let(
          paths.filter_map { |_, path| load_path_files(path) }.flatten,
          T.nilable(T::Array[T::Hash[String, T.untyped]])
        )
    end

    private

    # FIXME
    sig { returns(T.untyped) }
    def paths
      ::Rails::Engine
        .subclasses
        .map(&:instance)
        .filter { |instance| instance.paths.path.dirname.to_s.include?('components') }
        .map do |instance|
          pathname = instance.paths.path
          namespace = instance.railtie_namespace.to_s.underscore
          [
            instance.class.module_parent.to_s,
            File.join(pathname.dirname, pathname.basename, 'app', 'resources', namespace).to_s
          ]
        end
    end

    sig { params(path: String).returns(T::Array[T::Hash[String, T.untyped]]) }
    def load_path_files(path)
      files = Dir.glob(File.join(path, '**', '*.yml'))
      files.filter_map do |file|
        fcontent = File.open(file)

        YAML.safe_load(fcontent.read, permitted_classes: [Symbol])
      end
    end
  end
end
