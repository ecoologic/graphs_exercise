class RailwayQuery
  def initialize(vertexes)
    @vertexes = vertexes
  end

  def instructions
    "\n* Welcome *\n"                                                                                   \
    "\nYour graph have been parsed into:\n#{vertexes.inspect}"                                          \
    "\nHere's some examples:\n"                                                                         \
    "\n\n4. The distance of the route A-E-B-C-D:"                                                       \
    "\n\tdistance A B C"                                                                       \
    "\n\n6. The number of trips starting at C and ending at C with a maximum of 3 stops max weight 99:" \
    "\n\tcount C C 1 3 99"                                                                         \
    "\n\n8. The length of the shortest route (in terms of distance to travel) from A to C."             \
    "\n\tshortest A C"                                                                                  \
  end

  def call(action, *params)
    case action.downcase.to_sym
    when :distance
      result = Graphs::HardPath.new(vertexes, nodes: params).weight
      result ? "The distance is #{result}." : "NO SUCH ROUTE"

    when :count
      result = Graphs::Path.new(
        vertexes,
        start:       params[0],
        destination: params[1]
      ).count(
        min_traverses: params[2].to_i,
        max_traverses: params[3].to_i,
        max_weight:    params[4].to_i)
      "There are #{result} paths."

    when :shortest
      result = Graphs::Path.new(
        vertexes,
        start:       params[0],
        destination: params[1]
      ).lightest

      "The shortest path has a distance of #{result}."

    else
      "Command not recognised"
    end
  end

  private
  attr_reader :vertexes, :nodes
end
