module Graphs
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

  ##############################################################################

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

  ##############################################################################

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

class RailwayQuery
  def initialize(vertexes)
    @vertexes = vertexes
  end

  def call(action, *params)
    case action.downcase.to_sym
    when :fix_path_distance
      # TODO: not_found
      result = Graphs::HardPath.new(vertexes, nodes: params).weight
      "The distance is #{result}."
    when :path_count
      result = Graphs::Path.new(
        vertexes,
        start: params[0],
        destination: params[1]
      ).count(min_traverses: params[2].to_i, max_traverses: params[3].to_i)
      "There are #{result} paths."
    else
      "Command not recognised"
    end
  end

  private
  attr_reader :vertexes, :nodes
end

class Console
  DEFAULT_READ_STRATEGY = ->(*) { STDIN::gets.chomp }
  DEFAULT_WRITE_STRATEGY = ->(*args) { puts *args }

  def initialize(file_path, read_strategy: DEFAULT_READ_STRATEGY, write_strategy: DEFAULT_WRITE_STRATEGY)
    @read_strategy  = read_strategy
    @write_strategy = write_strategy
    @raw_vertexes_s = File.read(file_path)
    @vertexes = Graphs::Parser.new(raw_vertexes_s).vertexes
  end

  def call
    display_instructions
    execute_actions

    say "\n* Bye *\n\n"
  end

  private

  attr_reader :raw_vertexes_s, :vertexes, :read_strategy, :write_strategy

  def display_instructions
    say "\n* Welcome *\n"
    say "Your graph is: " + raw_vertexes_s
    say "Which have been parsed into: " + vertexes.inspect
    say "Here's some examples:\n"
    say "\n4. The distance of the route A-E-B-C-D:"
    say "\tfix_path_distance A B C"
    say "\n6. The number of trips starting at C and ending at C with a maximum of 3 stops:"
    say "\tpath_count C C 1 3"
  end

  def get_input
    read_strategy.()
  end

  def say(*args)
    write_strategy.(*args)
  end

  def execute_actions
    say "\nExit with an empty line"
    until (input = get_input) == '' do
      say RailwayQuery.new(vertexes).call(*input.upcase.split(' '))
    end
  end
end
