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

  if !move_count.zero?
    $prompt.say("Err there are #{move_count} records in the DB", color: :red)
    destroy = $prompt.ask("Do you want to clear the records?", default: "n")
    if destroy&.downcase == "y"
      Move.destroy_all 
      $prompt.say("Database cleared.", color: :green)
    end
  end 

  # Fetch the initial list of moves
  response = HTTParty.get($move_endpoint)
  return nil if response.empty? || response["results"].empty?
  
  moves_list = response["results"]

  # 1. Initialize the Progress Bar
  # We use :item_name as a placeholder for the move being processed
  bar = TTY::ProgressBar.new(
    "Parsing :item_name [:bar] :percent", 
    total: moves_list.count, 
    width: 30
  )

  moves_list.each do |move| 
    # 2. Update the label and advance the bar
    # .ljust(20) ensures the bar doesn't jump around if names vary in length
    bar.advance(item_name: move["name"].ljust(20))

    move_datum = HTTParty.get(move["url"])
    short_txt = move_datum['effect_entries'].find { |e| e['language']['name'] == 'en' }

    model = Move.create(
      name: move["name"].split("-").join(" "),
      url: move["url"],
      move_type: move_datum['type']['name'],
      power: move_datum['power'] || 'data not available',
      short_text: short_txt ? short_txt['short_effect'] : 'ERR NO DATA',
    )
    
    next if model.nil? # Use next instead of return nil to keep the loop going
    
    # Small sleep so the user can actually see the progress bar movement
    sleep(0.1) 
  end

  # Final status check
  final_count = Move.count
  if !final_count.zero?
    $prompt.say("\nSuccess! Moves Table has been built!", color: :magenta)
    return true
  else
    $prompt.say("\nFailure! Moves Table failed to build!", color: :cyan)
    return false
  end
end

  def make_move_model(move_url: nil)
    return nil if move_url.nil?
    move_dat = get_move_by_url(url: move_url)
    return nil if move_dat.empty?
    short_effect = move_dat['effect_entries'].find { |entry| entry['language']['name'] == 'en' }
    $prompt.say("Success Move Node created for { #{move_dat['name']} }", color: :blue)
    move = Move.create(
      name: move_dat['name'],
      url: move_url,
      move_type: move_dat['type']['name'],
      power: move_dat['power'] ||= 'data_not available from the pokeapi',
      short_text: short_effect ? short_effect['short_effect'] : "ERR"
    )


    return move


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


  
def assign_learned_moves()
  return nil if Move.count.zero?
  moves = Move.all
  moves.each do |move|
    move_data = HTTParty.get(move.url)
    next if move_data.empty? || move_data['learned_by_pokemon'].empty?

    move_data['learned_by_pokemon'].each do |pokemon|
      pkmn_record = Pokemon.find_by(name: pokemon['name'])
      next if pkmn_record.nil?

      PokemonMove.create(
        pokemon_id: pkmn_record.poke_id,
        move_id: move.id
      )
    end
  end

  return true
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
