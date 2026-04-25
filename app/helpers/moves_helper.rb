module MovesHelper
  $move_endpoint = "https://pokeapi.co/api/v2/move/"
  def build_items_map
    map = []
    moves = HTTParty.get($move_endpoint)
    return nil if moves.empty? || moves["results"].empty?
    (1..moves['count']).each do |i|
      move = HTTParty.get("#{$move_endpoint}#{i}")
      map.push(*move["results"].map {|m| {name: m['name'], url: m['url']}})
    end
    return map unless map.empty?
  end
end
