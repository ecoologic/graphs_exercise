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
    say "\n6. The number of trips starting at C and ending at C with a maximum of 3 stops max weight 99:"
    say "\tpath_count C C 1 3 99"
    say "\n8. The length of the shortest route (in terms of distance to travel) from A to C."
    say "\tshortest A C"
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
