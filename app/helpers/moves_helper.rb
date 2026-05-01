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
  format = "Loading #{$pastel.bright_red("Loading moves..")} [:bar] :percent"
  options = {
    total: Move.count,
    width: 40,
    complete: $pastel.black.on_green("."),
    incomplete: $pastel.bright_red.on_black(" "),
    clear: true
  }
  $bar = TTY::ProgressBar.new(format, options)
  $prompt = TTY::Prompt.new

  def reset_bar()
    $bar.finish()
    $bar.reset()
  end

  # Build the tables and their relations
  def build_moves_from_restapi
    move_count = Move.count
    build_success = false

    # check for records and offer destruction before rebuild 
    if !move_count.zero?
      $prompt.say("Err there are #{move_count} records in the DB", color: :red)
      destroy = $prompt.ask("Do you want to clear the records?", default: "n")
      destroy = destroy.downcase


    end 

    moves = HTTParty.get($move_endpoint)
    return nil if moves.empty? || moves["results"].empty?

    moves["results"].each do |move| 
      move_datum = HTTParty.get(move["url"])
      short_txt = move_datum['effect_entries'].find { |e| e['language']['name'] == 'en'}

      move_types = Type.find_by(name: move_datum['type']['name'])

      model = Move.create(
        name: move["name"].split("-").join(" "), # this just puts the moves name if it doesnt have a hyphen
        url: move["url"],
        move_type: move_datum['type']['name'],
        power: move_datum['power'] ||= 'data not available',
        short_text: short_txt['short_effect'] ||= 'ERR NO DATA',
        type_id: move_types.id ||= nil
      )
      return nil if model.nil?

      $prompt.say("Success created model for #{model.name}", color: :cyan)
      sleep(0.1)
      $bar.advance()
    end

    move_count = Move.count
    reset_bar()

    $prompt.say("Success! Moves Table has been built!", color: :magenta) if !move_count.zero?
    $prompt.say("Failure! Moves Table failed to build!", color: :cyan) if move_count.zero?

    return (Move.count.zero?) ? false : true
  end

  def make_move_model(move_url: nil)
    return nil if move_url.nil?
    move_dat = get_move_by_url(url: move_url)
    return nil if move_dat.empty?
    short_effect = move_dat['effect_entries'].find { |entry| entry['language']['name'] == 'en' }
    $prompt.say("Success Move Node created for { #{move_dat['name']} }", color: :blue)

    return Model.create(
      name: move_dat['name'],
      url: move_url,
      move_type: move_dat['type']['name'],
      power: move_dat['power'] ||= 'data_not available from the pokeapi',
      short_text: short_effect ? short_effect['short_effect'] : "ERR"
    )
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
