module Graphs
  class Path
    def initialize(vertexes, start:, destination:)
      @vertexes, @start, @destination = vertexes, start, destination
    end

    def count(options = {})
      options = default_options.merge(options)
      path_count = 0
      traverse(start, destination, options, blank_history) { path_count += 1 }
      path_count
    end

    def lightest
      all_nodes = vertexes.each.reduce [] do |nodes, (node, weights)|
        nodes + [node] + weights.keys
      end

      weights = all_nodes.reduce({}) do |weights, node|
        weights.merge node => Float::INFINITY
      end

      weights[start] = 0

      if start == destination # Point #9
        all_nodes.delete(start)
        weights[start] = Float::INFINITY
        vertexes[start].each { |node, weight| weights[node] = weight }
      end

      while all_nodes.any? do
        min_node = all_nodes.min { |a, b| weights[a] <=> weights[b] }

        return if [nil, Float::INFINITY].include?(min_node)

        all_nodes.delete(min_node)

        vertexes[min_node].each_key do |node|
          weight = weights[min_node] + (vertexes[min_node][node] || Float::INFINITY)
          weights[node] = weight if weights[node] && weight < weights[node]
        end
      end

      weights[destination] != Float::INFINITY && weights[destination]
    end

    private

    attr_reader :vertexes, :start, :destination

    def traverse(current_node, destination, options, history, &callback)
      found       = current_node == destination
      shortest_ok = history[:traverse_count] >= options[:min_traverses]
      longest_ok  = history[:traverse_count] <= options[:max_traverses] &&
                    history[:weight]         <= options[:max_weight]

      if found && shortest_ok && longest_ok
        # puts "FOUND #{history[:path]}"
        yield history
      end

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
  end
end
