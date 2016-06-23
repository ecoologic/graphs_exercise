class Console
  DEFAULT_READ_STRATEGY = ->(*) { STDIN::gets.chomp }
  DEFAULT_WRITE_STRATEGY = ->(*args) { puts *args }

  def initialize(file_path, read_strategy: DEFAULT_READ_STRATEGY, write_strategy: DEFAULT_WRITE_STRATEGY)
    @read_strategy  = read_strategy
    @write_strategy = write_strategy

    assert_file(file_path)
    raw_vertexes_s = File.read(file_path)
    vertexes       = Graphs::Parser.new(raw_vertexes_s).vertexes
    @query         = RailwayQuery.new(vertexes)
  end

  def call
    display_instructions
    execute_actions

    say "\n* Bye *\n\n"
  end

  private

  attr_reader :query, :read_strategy, :write_strategy

  def display_instructions
    say query.instructions
  end

  def get_input
    read_strategy.()
  end

  def say(*args)
    write_strategy.(*args)
  end

  def execute_actions
    say "\nExit with an empty line"
    until (input = get_input).gsub(' ', '') == ''
      say query.call(*input.upcase.split(' '))
    end
  end

  def assert_file(path)
    return if File.exist?(path.to_s)
    say "Missing file, try: ruby run.rb fixtures/example_graph.txt"
    exit
  end
end
