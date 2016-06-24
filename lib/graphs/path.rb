module Graphs
  # An intention of going from one node to another
  class Path
    def initialize(vertexes, start:, destination:)
      @vertexes, @start, @destination = vertexes, start, destination
    end

    def lightest
      nodes = Dijkstra.shortest_path(vertexes, starts: start, ends: destination)
      HardPath.new(vertexes, nodes: nodes).weight
    end

    def count(options = {})
      options = default_options.merge(options)
      path_count = 0
      traverse(start, destination, options, blank_history) { path_count += 1 }
      path_count
    end

    private

    attr_reader :vertexes, :start, :destination

    def traverse(current_node, destination, options, history, &callback)
      found       = current_node == destination
      shortest_ok = history[:traverse_count] >= options[:min_traverses]
      longest_ok  = history[:traverse_count] <= options[:max_traverses] &&
                    history[:weight]         <= options[:max_weight]

      yield history if found && shortest_ok && longest_ok

      # Run even when a path is found (Point #10)
      if longest_ok
        vertexes[current_node].each do |next_node, weight|
          # Now re-passing the same node multiple times (Point #7)
          # next if (history[:path] - [destination]).include?(next_node)
          updated_history = {
            weight:         history[:weight] + weight,
            traverse_count: history[:traverse_count] + 1,
            path:           history[:path] + [current_node]
          }
          traverse(next_node,
                   destination,
                   options,
                   updated_history,
                   &callback)
        end
      end
    end

    def blank_history
      { path: [], weight: 0, traverse_count: 0 }
    end

    def default_options
      { min_traverses: 1, max_traverses: 1_000, max_weight: 1_000 }
    end

    def all_nodes
      vertexes.each.reduce [] do |result, (node, weights)|
        result + [node] + weights.keys
      end.uniq
    end

    def infinite_weights
      all_nodes.reduce({}) do |result, node|
        result.merge node => Float::INFINITY
      end
    end
  end
end
