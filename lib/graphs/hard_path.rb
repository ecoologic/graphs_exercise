module Graphs
  # A very specific path identified by a list of node names
  class HardPath
    def initialize(vertexes, nodes:)
      @vertexes, @nodes = vertexes, nodes
    end

    def weight
      weight = 0
      nodes.each_with_index do |node, i|
        next_node = nodes[i + 1] or break
        weight += vertexes[node][next_node] || (return false)
      end
      weight
    end

    private
    attr_reader :vertexes, :nodes
  end
end
