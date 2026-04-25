module MovesHelper
  $move_endpoint = "https://pokeco.api/api/v2/move/"
  def build_items_map
    moves = HTTParty.get($move_endpoint)
    map = moves.map {|m| {name: m['name'], url: m['url']}}

    return map unless map.empty?
  end
end
