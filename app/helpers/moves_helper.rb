module MovesHelper
  $move_endpoint = "https://pokeapi.co/api/v2/move/"
  def build_items_map
    map = []
    moves = HTTParty.get($move_endpoint)
    return nil if moves.empty? || moves["results"].empty?
    (0..moves['count']).step(100) do |i|
      move = HTTParty.get("#{$move_endpoint}#{i}")
      map.push({name: move['name'], url: move['url']}) if !move.empty? && !move['name'].empty? && !move['url'].empty
    end
    return map unless map.empty?
  end
end
