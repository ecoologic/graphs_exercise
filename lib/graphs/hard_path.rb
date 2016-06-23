module Graphs
  class HardPath
    def initialize(vertexes, nodes:)
      @vertexes, @nodes = vertexes, nodes
    end

    def weight(not_found: "NO SUCH ROUTE")
      weight = 0
      nodes.each_with_index do |node, i|
        next_node = nodes[i + 1] or break
        weight += vertexes[node][next_node] || (return not_found)
      end
      weight
    end

    private
    attr_reader :vertexes, :nodes
  end
end
