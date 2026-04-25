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

  def build_moves_node_map
    map = []
    if $moves_name_url_map.nil? || $moves_name_url_map.empty?
      moves = build_moves_map()
    else
      moves = $move_name_url_map
    end

    return nil if moves.nil? || moves.empty?

    moves.each do |move|
      move_data = get_move_by_url(url: move[:url])
      next if move_data.nil? || move_data['name'].empty?
      puts "building move node for #{move_data['name']}"
      en_short_text = move_data['effect_entries'].find { |entry| entry['language']['name'] == 'en' }
      map.push({
        name: move[:name],
        url: move[:url],
        move_type: move_data['type']['name'],
        power: move_data['power'],
        short_text: (en_short_text['short_effect'].empty?) ? "N.A" : en_short_text['short_effect'] 
      })
    end
    $move_nodes_map = map unless map.empty?
    return map unless map.empty?
  end
end
