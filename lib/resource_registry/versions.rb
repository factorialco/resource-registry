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

    sig do
      params(name_or_version: T.any(String, Version)).returns(
        T.nilable(Version)
      )
    end
    def find_next(name_or_version)
      version =
        name_or_version.is_a?(String) ? find!(name_or_version) : name_or_version
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
      versions.select do |version|
        (from.nil? || version >= from) && (to.nil? || version <= to)
      end
    end

    private

    sig { returns(T::Array[Version]) }
    attr_reader :versions
  end
end
