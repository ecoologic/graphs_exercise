# See README
# $ ruby run.rb fixtures/example_graph.txt

require_relative 'lib/app'

require_relative 'lib/console'
require_relative 'lib/railway_query'

Console.new(ARGV.first).call
