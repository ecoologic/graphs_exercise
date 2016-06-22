module Graphs
  class Parser
    VERTEX_REGEX = /(\w)(\w)(\d+)/

    # eg: raw_vertexes_s = "AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7"
    def initialize(raw_vertexes_s)
      @raw_vertexes_s = raw_vertexes_s
    end

    # eg: { 'A' => { 'B' => 5 }, 'B' => { 'C' => 4 } }
    def vertexes
      @vertexes ||= vertexes_parts.reduce({}) do |result, (current_node, end_node, weight)|
        result[current_node.upcase] ||= {}
        result[current_node.upcase][end_node.upcase] = weight.to_i
        result
      end
    end

    private
    attr_reader :raw_vertexes_s

    # eg: "AB1 CD2" -> [["A", "B", "1"], ["C", "D", "2"]]
    def vertexes_parts
      raw_vertexes_s.scan(VERTEX_REGEX)
    end
  end

  ##############################################################################

  class Weight
    # vertexes: { 'A' => { 'B' => 5 } }
    def initialize(vertexes)
      @vertexes = vertexes
    end

    # TODO: extract view resp
    # TODO: single point of exit (catch)
    def call(nodes, no_such_route: "NO SUCH ROUTE")
      weight = 0
      nodes.each_with_index do |node, i|
        next_node = nodes[i + 1] or break
        weight += vertexes[node][next_node] || (return no_such_route)
      end
      weight
    end

    private
    attr_reader :vertexes
  end

  ##############################################################################

  class Path
    def initialize(vertexes)
      @vertexes = vertexes
    end

    def length(start, destination, options = {})
      options = default_options.merge(options)
      node_count = 0
      traverse(start, destination, options, blank_history) { node_count += 1 }
      node_count
    end

    private
    attr_reader :vertexes

    def traverse(current_node, destination, options, history, &callback)
      found       = current_node == destination
      shortest_ok = history[:traverse_count] >= options[:min_traverses]
      longest_ok  = history[:traverse_count] <= options[:max_traverses] &&
                    history[:weight]         <= options[:max_weight]

      if found && shortest_ok && longest_ok
        puts "FOUND #{history[:path]}"
        yield callback
      elsif longest_ok
        vertexes[current_node].each do |next_node, weight|
          # Re-passing required for point 7
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
