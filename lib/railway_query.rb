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
