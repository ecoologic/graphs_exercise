module Graphs
  class Path
    def initialize(vertexes, start:, destination:)
      @vertexes, @start, @destination = vertexes, start, destination
    end

    def lightest
      remaining_nodes = all_nodes
      weights         = infinite_weights

      if start == destination # Point #9 start and end in the same route
        vertexes[start].each { |node, weight| weights[node] = weight }
        remaining_nodes.delete(start)
        weights[start] = Float::INFINITY
      else
        weights[start] = 0
      end

      until remaining_nodes.empty?
        lightest_node = remaining_nodes.min { |a, b| weights[a] <=> weights[b] }
        remaining_nodes.delete(lightest_node)
        break false if lightest_node == Float::INFINITY

        vertexes[lightest_node].each_key do |node|
          weight = weights[lightest_node] + (vertexes[lightest_node][node] || Float::INFINITY)
          weights[node] = weight if weight < weights[node]
        end
      end

      weights[destination] != Float::INFINITY && weights[destination]
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

      # Must run even when a path is found to satisfy Point #10
      if longest_ok
        vertexes[current_node].each do |next_node, weight|
          # Re-passing required for Point #7
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
      vertexes.each.reduce [] do |nodes, (node, weights)|
        nodes + [node] + weights.keys
      end.uniq
    end

    def infinite_weights
      all_nodes.reduce({}) do |weights, node|
        weights.merge node => Float::INFINITY
      end
    end
  end
end
