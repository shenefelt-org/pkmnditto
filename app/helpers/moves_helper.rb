module MovesHelper
  $move_endpoint = "https://pokeapi.co/api/v2/move?limit=950"
  $moves_map = nil
  def build_moves_map
    map = []
    moves = HTTParty.get($move_endpoint)
    return nil if moves.empty? || moves["results"].empty?
    moves["results"].map { |move| map.push({name: move['name'], url: move['url']}) }
    $moves_map = map unless map.empty?
    return map unless map.empty?
  end

  def get_all_moves_info
    moves = build_moves_map() if $moves_map.nil? || $moves_map.empty?
    return nil if moves.nil? || moves.empty?
  end
end
