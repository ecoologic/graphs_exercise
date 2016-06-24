# A wrapper between the user request and the graph logic
# TODO? RailwayController ?
class RailwayQuery
  def initialize(vertexes)
    @vertexes = vertexes
  end

  def instructions
    "\nYour graph have been parsed into:\n#{vertexes.inspect}"                 \
    "\nHere's some examples:\n"                                                \
    "\n\n4. The distance of the route A-E-B-C-D:"                              \
    "\n\tdistance A B C"                                                       \
    "\n\n6. The number of trips starting at C and ending at C with a maximum of 3 stops max weight 99:" \
    "\n\tcount C C 1 3 999"                                                                             \
    "\n\n8. The length of the shortest route (in terms of distance to travel) from A to C."             \
    "\n\tshortest A C"                                                         \
    "\nHere's the rest:\n"                                                     \
    "\n\tdistance a b c        # 1) 9"                                         \
    "\n\tdistance a d          # 2) 5"                                         \
    "\n\tdistance a d c        # 3) 13"                                        \
    "\n\tdistance a e b c d    # 4) 22"                                        \
    "\n\tdistance a e d        # 5) NO SUCH ROUTE"                             \
    "\n\tcount C C 1 3 999     # 6) 2"                                         \
    "\n\tCOUNT A C 4 4 999     # 7) 3"                                         \
    "\n\tshortest a c          # 8) 9"                                         \
    "\n\tshortest b b          # 9) 9"                                         \
    "\n\tcount c c 1 999 29    # 10) 7"                                        \
    "\n\t"                                                                     \
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
