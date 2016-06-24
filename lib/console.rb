# What the user will use in the shell to interact with the app
class Console
  DEFAULT_READ_STRATEGY = ->(*) { STDIN::gets.chomp }
  DEFAULT_WRITE_STRATEGY = ->(*args) { puts *args }

  def initialize(file_path, read_strategy: DEFAULT_READ_STRATEGY, write_strategy: DEFAULT_WRITE_STRATEGY)
    @file_path      = file_path
    @read_strategy  = read_strategy
    @write_strategy = write_strategy
  end

  def call
    say "\n* Welcome *\n"                                                          \

    say query.instructions

    execute_actions

    say "\n* Bye *\n\n"
  end

  private

  attr_reader :file_path, :read_strategy, :write_strategy

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

  def query
    @query ||= begin
      unless File.exist?(file_path.to_s)
        say "Missing file, try: ruby run.rb fixtures/example_graph.txt"
        exit
      end

      raw_vertexes_s = File.read(file_path)
      vertexes       = Graphs::Parser.new(raw_vertexes_s).vertexes
      RailwayQuery.new(vertexes)
    end
  end
end
