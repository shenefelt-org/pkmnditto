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
  @prompt = TTY::Prompt.new
  @pastel = Pastel.new
  format = "Loading #{@pastel.bright_red("Loading moves :name")} [:bar] :percent"
  @move_endpoint = "https://pokeapi.co/api/v2/move?limit=950"
  @bar = TTY::ProgressBar.new(format, options)
  options = {
    total: Move.count,
    width: 40,
    complete: @pastel.black.on_green("="),
    incomplete: @pastel.bright_red.on_black("-"),
    clear: false
  }


def build_moves_from_graphql
  move_count = Move.count

  if !move_count.zero?
    @prompt.warn("Moves DB already contains #{move_count} records.")
    if @prompt.yes?("Do you want to clear them?")
      Move.destroy_all 
      @prompt.ok("Database cleared.")
    end
  end

  # Define the GraphQL Query
  # We fetch the name, power, type name, and the english effect text in one go
  query = <<~GQL
    query GetMoves {
      pokemon_v2_move {
        name
        power
        pokemon_v2_type {
          name
        }
        pokemon_v2_moveeffect {
          pokemon_v2_moveeffecttexts(where: {language_id: {_eq: 9}}) {
            short_effect
          }
        }
      }
    }
  GQL

  @prompt.say("Fetching moves data from GraphQL API...", color: :cyan)
  
  response = HTTParty.post(
    "https://beta.pokeapi.co/graphql/v1beta",
    headers: { 'Content-Type' => 'application/json' },
    body: { query: query }.to_json
  )

  unless response.success? && response["data"]
    @prompt.error("Failed to fetch data from GraphQL endpoint.")
    return false
  end

  moves_data = response["data"]["pokemon_v2_move"]

  # Update progress bar total if necessary
  # @bar.total = moves_data.length 

  moves_data.each do |move_datum|
    # Format the name (e.g., "thunder-punch" -> "Thunder Punch")
    formatted_name = move_datum["name"].split("-").map(&:capitalize).join(" ")
    
    @bar.advance(item_name: formatted_name.ljust(20))

    # Extract the effect text safely
    effect_array = move_datum.dig("pokemon_v2_moveeffect", "pokemon_v2_moveeffecttexts")
    short_txt = effect_array&.first ? effect_array.first["short_effect"] : "No description available"

    Move.create(
      name: formatted_name,
      move_type: move_datum.dig("pokemon_v2_type", "name"),
      power: move_datum["power"] || 0,
      short_text: short_txt
    )
    
    # Optional: Small sleep to prevent UI flickering, 
    # but no longer needed for rate limiting since it's one request!
    sleep(0.01) 
  end

  if Move.count > 0
    @prompt.say("\nSuccess! Moves Table has been built with #{Move.count} records!", color: :magenta)
    return true
  else
    @prompt.error("\nFailure! No moves were saved to the database.")
    return false
  end
end

  def make_move_model(move_url: nil)
    return nil if move_url.nil?
    move_dat = get_move_by_url(url: move_url)
    return nil if move_dat.empty?
    short_effect = move_dat['effect_entries'].find { |entry| entry['language']['name'] == 'en' }
    @prompt.say("Success Move Node created for { #{move_dat['name']} }", color: :blue)

    Move.create(
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
