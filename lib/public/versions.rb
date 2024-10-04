# typed: strict

module ResourceRegistry
  class Versions
    extend T::Sig
    extend T::Helpers

    sig { params(versions: T::Array[Version]).void }
    def initialize(versions:)
      @versions = versions
    end

    sig { params(name: T.nilable(String)).returns(T.nilable(Version)) }
    def find(name)
      return if name.blank?

      versions.find { |version| version.matches?(name) }
    end

    sig { params(name: String).returns(Version) }
    def find!(name)
      find(name) || raise("Version '#{name}' not found")
    end

    sig { params(name: String).returns(T.nilable(Version)) }
    def find_next(name)
      version = find!(name)
      index = T.must(sorted_versions.index(version))

      sorted_versions[index + 1]
    end

    sig { returns(T::Array[Version]) }
    def sorted_versions
      versions.sort
    end

    sig do
      params(from: T.nilable(String), to: T.nilable(String)).returns(
        T::Array[ResourceRegistry::Versions::Version]
      )
    end
    def in_range(from, to)
      from = find!(from) unless from.nil?
      to = find!(to) unless to.nil?
      versions.select { |version| (from.nil? || version >= from) && (to.nil? || version <= to) }
    end

    private

    sig { returns(T::Array[Version]) }
    attr_reader :versions
  end
end
