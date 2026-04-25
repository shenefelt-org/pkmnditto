module MovesHelper
  $move_endpoint = "https://pokeapi.co/api/v2/move?limit=950"
  $moves_name_url_map = nil
  $move_nodes_map = nil

  def build_moves_map
    map = []
    moves = HTTParty.get($move_endpoint)
    return nil if moves.empty? || moves["results"].empty?
    moves["results"].map { |move| map.push({name: move['name'], url: move['url']}) }
    $moves_name_url_map = map unless map.empty?
    return map unless map.empty?
  end

  def get_move_by_url(url: nil)
    return nil if url.nil?
    move_info = HTTParty.get(url)
    return nil if move_info.empty?
  end

  def make_move_node(move_url: nil)
    return nil if move_url.nil?
    move_dat = get_move_by_url(url: move_url)
    return nil if move_dat.empty?
    short_effect = move_dat['effect_entries'].find { |entry| entry['language']['name'] == 'en' }
    return {
      name: move_dat['name'],
      url: move_url,
      move_type: move_dat['type']['name'],
      power: move_dat['power'],
      short_text: short_effect ? short_effect['short_effect'] : "ERR"
    }
  end

  def get_move_url_by_name(move_name: nil)
  end

  def build_moves_node_map
    map = []
    $moves_name_url_map = build_moves_map() if $moves_name_url_map.nil? || $moves_name_url_map.empty?
    return nil if $moves_name_url_map.nil? || $moves_name_url_map.empty?

    $moves_name_url_map.each do |move|
      move_dat = get_move_by_url(url: move[:url])
      break if move_dat.nil?
      short_effect = move_dat['effect_entries'].find { |entry| entry['language']['name'] == 'en' }
      map.push({
        name: move[:name],
        url: move[:url],
        move_type: move_dat['type']['name'],
        power: move_dat['power'],
        short_text: short_effect ? short_effect['short_effect'] : "ERR"
      })
    end
    $move_nodes_map = map unless map.empty?
    return map unless map.empty?
  end
end
