# typed: strict

class Forge
  # The `Artifact` class represents the result of a `Synthesizer` in the form of
  # a file that can be written to disk.
  class Artifact
    extend T::Sig

    sig { params(content: String, path: String).void }
    def initialize(content:, path:)
      @content = content
      @path = path
    end

    sig { returns(String) }
    attr_reader :content

    sig { returns(String) }
    attr_reader :path

    sig { void }
    def write!
      File.write(path, content)
    end
  end
end
