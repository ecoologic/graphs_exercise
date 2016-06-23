module Graphs
  # Converts a string into the vertexes,
  # which are links between nodes with their weight
  class Parser
    VERTEX_REGEX = /(\w)(\w)(\d+)/m

    # eg: raw_vertexes_s = "AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7"
    # todo: nodes
    def initialize(raw_vertexes_s)
      @raw_vertexes_s = raw_vertexes_s
    end

    # result: { 'A' => { 'B' => 5 }, 'B' => { 'C' => 4 } }
    def vertexes
      @vertexes ||= vertexes_parts.reduce({}) do |result, (start_node, end_node, weight)|
        result[start_node.upcase] ||= {}
        result[start_node.upcase][end_node.upcase] = weight.to_i
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
end
