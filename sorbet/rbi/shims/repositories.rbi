# typed: strict

# FIXME: This is a patch for some Factorial abstractions that haven't quite been
# removed from the gem yet. Once a clearer boundary is established, this should
# be removed.
module Repositories
  module ReadResult
  end
  class InMemoryReadResult
  end
  module ReadOutputContext
  end
  module OutputContexts
    class Filter
    end
  end
end
