# temp fix for tty table err
# Add this BEFORE any TTY requires
unless defined?(Fixnum)
  Fixnum = Integer
end

unless defined?(Bignum)
  Bignum = Integer
end

require 'tty'
require 'tty-prompt'
require 'tty-progressbar'
require "pastel"

module MovesHelper
  $move_endpoint = "https://pokeapi.co/api/v2/move?limit=950"
  $moves_map = []
  $move_nodes_map = []
  $pastel = Pastel.new
  format = "#{$pastel.green("Destroying Pokemon.. ")} [ :bar ] :percent | Elapsed: :elapsed | ETA: :eta "
  $bar = TTY::ProgressBar.new(format, total: Move.count, complete: "°", incomplete: " ")
  $prompt = TTY::Prompt.new



  def build_moves_map
    map = []
    moves = HTTParty.get($move_endpoint)
    return nil if moves.empty? || moves["results"].empty?
    moves["results"].map { |move| map.push({name: move['name'], url: move['url']}) }
    $moves_map = map unless map.empty?
    return map unless map.empty?
  end

  def build_moves_from_restapi
    $moves_map = build_moves_map() if $moves_map.blank? || $moves_map.empty?
    $moves_node_map = []
    
    return nil if $moves_map.blank?

    $moves_map.each do |move|
      move_node = make_move_model(move_url: move[:url])
      $prompt.say("Success Move Model created for #{move_node.name}", color: :blue, style: :italic) unless move_node.nil?
      $moves_node_map.push(move_node) unless move_node.nil?
      sleep(0.1)
      $bar.advance
    end

    $bar.finish()
    $bar.reset()
    $prompt.say("-> Success! Move node map built successfully!", color: :magenta, style: :italic) unless $moves_node_map.empty?
    $prompt.say("-> Failure! Node Map Failed To Build..", color: :red, style: :italic) if $moves_node_map.empty?
    return $moves_node_map unless $moves_node_map.empty?
  end

  def make_move_node(move_url: nil)
    return nil if move_url.nil?
    move_dat = get_move_by_url(url: move_url)
    return nil if move_dat.empty?
    short_effect = move_dat['effect_entries'].find { |entry| entry['language']['name'] == 'en' }
    $prompt.say("Success Move Node created for { #{move_dat['name']} }", color: :blue)
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
    $prompt.say("Fetching move data from url: #{url}", color: :yellow)
    move_info = HTTParty.get(url)
    return nil if move_info.empty?
    $prompt.say("Success featched move data from url: #{url}", color: :green)
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
    move = make_move_node(move_url: move_url)
    return nil if move.empty?
    return Move.create(
      name: move[:name],
      url: move_url,
      move_type: move[:move_type],
      power: move[:power] ||= 'data_not available from the pokeapi',
      short_text: move[:short_text]
    )

    
  end

  
def get_learned_by(pokemon_id: nil)
  return nil if pokemon_id.nil?
    
  # Fetch the specific Pokémon
  res = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{pokemon_id}")
  return nil if res.blank? || res["moves"].blank?
  pkmn = Pokemon.find_by(poke_id: pokemon_id)

  pokemon_moves = []

  res["moves"].each do |move_entry|
      # 1. Dig the name and level
    name = move_entry.dig("move", "name")
    level = move_entry.dig("version_group_details", 0, "level_learned_at")
      
      # 2. Check if the move already exists in your DB to save time/API calls
    move_node = Move.find_by(name: name)

      # 3. If it doesn't exist, use your existing logic to fetch detail and create it
    if move_node.nil?
      move_url = move_entry.dig("move", "url")
      move_node = make_move_model(move_url: move_url)
    end

    pokemon_moves << { move: move_node, level: level }
    end

    return false if pokemon_moves.empty?
    pokemon_moves.each do |pm|
      move = Move.find_by(name: pm[:move].name)
      return nil if move.nil?
      pkmn.moves << move
    end
end

def move_weaknesses(move_name: nil)
  return nil if move_name.nil?
  move = Move.find_by(name: move_name)
  return unless move
  move_type = move.move_type
  type = Type.find_by(name: move_type)
  return nil unless type
  damage_relation = DamageRelation.find_by(type_id: type.id)
  return nil unless damage_relation

  # Get the types that are weak to this move's type
  weaknesses = damage_relation.double_damage_to
  return weaknesses unless weaknesses.empty?
  return nil
end


  

end
