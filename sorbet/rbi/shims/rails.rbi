# typed: strict

module Rails
  sig { returns(T.untyped) }
  def self.root
  end

  class Engine
  end
end

module ActionDispatch
  module Http
    class UploadedFile
    end
  end
end
