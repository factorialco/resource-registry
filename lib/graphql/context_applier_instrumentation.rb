# typed: strict

module ResourceRegistry
  module Graphql
    module ContextApplierInstrumentation
      module_function
      extend T::Sig

      ADHOC_CURSOR_FIELD = T.let('__after_query_filter_adhoc_cursor'.freeze, String)

      sig { params(hash: T.untyped, filtered_nodes: T.untyped).returns(T.untyped) }
      def replace_nodes(hash, filtered_nodes)
        return unless hash.is_a?(Hash)
        if hash.key?('nodes')
          hash['nodes'].replace(filtered_nodes)
          replace_page_info(hash, T.must(@nodes_applier))
        else
          hash.values.filter_map { |value| replace_nodes(value, filtered_nodes) }.first
        end
      end

      sig { params(hash: T.untyped, applier: Repositories::InMemoryContextApplier::Apply).void }
      def replace_page_info(hash, applier)
        hash['totalCount'] = applier.filtered_result.size if hash['totalCount']
        hash_page_info = hash['pageInfo']
        return unless hash_page_info

        page_info = applier.page_info
        hash_page_info.each { |key, _value| hash_page_info[key] = page_info.send(key.underscore) }
      end

      sig { params(hash: T.untyped, filtered_edges: T.untyped).returns(T.untyped) }
      def replace_edges(hash, filtered_edges)
        return unless hash.is_a?(Hash)
        if hash.key?('edges')
          hash['edges'].replace(
            filtered_edges.map do |edge|
              node_hash = { 'node' => edge.except(ADHOC_CURSOR_FIELD) }
              cursor = edge[ADHOC_CURSOR_FIELD]
              cursor ? node_hash.merge('cursor' => cursor) : node_hash
            end
          )
          replace_page_info(hash, T.must(@edges_applier))
        else
          hash.values.filter_map { |value| replace_edges(value, filtered_edges) }.first
        end
      end

      sig { params(hash: T.untyped, field: String).returns(T.untyped) }
      def find_field(hash, field)
        return unless hash.is_a?(Hash)
        if hash.key?(field)
          hash[field]
        else
          hash.values.filter_map { |value| find_field(value, field) }.first
        end
      end

      sig { params(query: T.untyped).returns(NilClass) }
      def before_query(query)
      end

      sig { params(query: T.untyped).returns(T.untyped) }
      def after_query(query)
        context = query.context[:in_memory_context]
        return unless context&.apply_after_query

        values = query.result.values
        nodes = find_field(values.first, 'nodes')
        edges = find_field(values.first, 'edges')

        apply_context_to_nodes(values, nodes, context) if nodes
        apply_context_to_edges(values, edges, context) if edges
      end

      sig { params(values: T.untyped, nodes: T.untyped, context: T.untyped).void }
      def apply_context_to_nodes(values, nodes, context)
        @nodes_applier ||=
          T.let(
            Repositories::InMemoryContextApplier::Apply.new(
              list: nodes,
              context: context,
              from_instrumentation: true
            ),
            T.nilable(Repositories::InMemoryContextApplier::Apply)
          )
        filtered_nodes = @nodes_applier.read_result(@nodes_applier.apply_all)
        replace_nodes(values.first, filtered_nodes)
      end

      sig { params(values: T.untyped, edges: T.untyped, context: T.untyped).void }
      def apply_context_to_edges(values, edges, context)
        @edges_applier ||=
          T.let(
            Repositories::InMemoryContextApplier::Apply.new(
              list:
                edges.map do |edge|
                  # This sucks, but we need to keep the edge cursor after filtering
                  node = edge['node']
                  cursor = edge['cursor']
                  node[ADHOC_CURSOR_FIELD] = cursor if cursor
                  node
                end,
              context: context,
              from_instrumentation: true
            ),
            T.nilable(Repositories::InMemoryContextApplier::Apply)
          )

        filtered_edges = @edges_applier.read_result(@edges_applier.apply_all)
        replace_edges(values.first, filtered_edges)
      end
    end
  end
end
