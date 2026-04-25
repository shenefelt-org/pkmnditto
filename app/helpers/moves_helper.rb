module MovesHelper
  $move_endpoint = "https://pokeapi.co/api/v2/move?limit=950"
  def build_moves_map
    map = []
    moves = HTTParty.get($move_endpoint)
    return nil if moves.empty? || moves["results"].empty?
    moves["results"].map { |move| map.push({name: move['name'], url: move['url']}) }
    return map unless map.empty?
  end
end
