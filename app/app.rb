module Graphs
  class Parser
    # eg: graph_s = "AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7"
    def initialize(graph_s)
      @graph_s = graph_s
    end

    def to_h
      @to_a ||= begin
        weighted_nodes = graph_s.split(' ')
        weighted_nodes.reduce({}) do |result, weighted_node|
          # weighted_node = 'AB5'
          start_node = weighted_node[0] # TODO? splat?
          end_node   = weighted_node[1]
          weight     = weighted_node[2].to_i

          result[start_node] ||= {}
          result[start_node][end_node] = weight
          result
        end
      end
    end

    private
    attr_reader :graph_s
  end

  # TODO: Weight
  class Distance
    # graph: { 'A' => { 'B' => 5 } }
    def initialize(graph)
      @graph = graph
    end

    def call(nodes)
      # more_nodes = nodes.dup # array fine to dup
      distance = 0
      nodes.each_with_index do |node, i|
        next_node = nodes[i + 1] or break
        distance += graph[node][next_node]
      end
      distance
    end

    private
    attr_reader :graph
  end
end
