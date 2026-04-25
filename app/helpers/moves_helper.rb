module MovesHelper
  $move_endpoint = "https://pokeapi.co/api/v2/move?limit=950"
  $moves_map = []
  $move_nodes_map = []

  def build_moves_map
    map = []
    moves = HTTParty.get($move_endpoint)
    return nil if moves.empty? || moves["results"].empty?
    moves["results"].map { |move| map.push({name: move['name'], url: move['url']}) }
    $moves_map = map unless map.empty?
    return map unless map.empty?
  end

  def build_moves_node_map
    $moves_map = build_moves_map() if $moves_map.blank? || $moves_map.empty?
    return nil if $moves_map.blank?

    $moves_map.each do |move|
      move_node = make_move_model(move_url: move[:url])
      $moves_node_map.push(move_node) unless move_node.nil?
    end

    return puts "move node map built successfully" unless $moves_node_map.empty?
    return puts "error building move node map"
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
      power: move_dat['power'] ||= 'data_not available from the pokeapi',
      short_text: short_effect ? short_effect['short_effect'] : "ERR"
    }
  end

  def get_move_by_url(url: nil)
    return nil if url.nil?
    move_info = HTTParty.get(url)
    return nil if move_info.empty?
    move_info
  end

  def get_move_url_by_name(move_name: nil)
    return nil if move_name.nil? || move_name.empty?
    $moves_map = build_moves_map() unless $moves_map.present? # check to make sure its present e.g. not blank flase or nil
    move = $moves_map.find { |m| m[:name] == move_name.downcase }
    return move[:url] if move.present?
    false # if we make it here no move was found by that name
  end

  def make_move_model(move_url: nil)
    move = make_move_node(move_url: "https://pokeapi.co/api/v2/move/10016")
    return nil if move.empty?
    return Move.create(
      name: move[:name],
      url: move_url,
      move_type: move[:move_type],
      power: move[:power] ||= 'data_not available from the pokeapi',
      short_text: move[:short_text]
    )

    
  end

end
