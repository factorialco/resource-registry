# typed: false

module ResourceRegistry
  module Tracer
    extend T::Sig

    sig do
      params(
        repository: T.untyped,
        verb: String,
        collection: T.nilable(T::Boolean),
        block: T.proc.returns(T.untyped)
      ).returns(T.untyped)
    end
    def self.trace_repository(repository, verb:, collection: false, &block)
      Telemetry::Tracer.trace(
        'api.repository',
        service: 'resource-registry',
        resource: "#{repository.class.name}##{verb}",
        tags: {
          component_name: repository.class.namespace.underscore,
          verb: verb,
          type: collection ? 'collection' : 'resource'
        }
      ) do
        # rubocop:disable Performance/RedundantBlockCall
        block.call
        # rubocop:enable Performance/RedundantBlockCall
      end
    end
  end
end
