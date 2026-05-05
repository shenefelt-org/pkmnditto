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
  options = {
    total: Move.count,
    width: 40,
    complete: @pastel.black.on_green("="),
    incomplete: @pastel.bright_red.on_black("-"),
    clear: false
  }
  @bar = TTY::ProgressBar.new(format, options)



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
  
def build_moves_from_graphql
  # 1. Check if DB has data
  move_count = Move.count
  if !move_count.zero?
    @prompt.warn("Moves DB already contains #{move_count} records.")
    if @prompt.yes?("Do you want to clear them?")
      Move.destroy_all 
      @prompt.ok("Database cleared.")
    end
  end

  # 2. Define the Query (Simplified 2026 Schema)
  # language_id 9 is English
  query = <<~GQL
    query GetMoves {
      move {
        name
        power
        type {
          name
        }
        move_effect {
          move_effect_texts(where: {language_id: {_eq: 9}}) {
            short_effect
          }
        }
      }
    }
  GQL

  @prompt.say("Connecting to GraphQL v1beta2 endpoint...", color: :cyan)
  
  # 3. Execute Request
  response = HTTParty.post(
    "https://graphql.pokeapi.co/v1beta2",
    headers: { 'Content-Type' => 'application/json' },
    body: { query: query }.to_json
  )

  # 4. Error Handling
  if response.code != 200 || response["data"].nil?
    @prompt.error("Fetch Failed! HTTP Status: #{response.code}")
    puts "Server Response: #{response.body}" # Critical for debugging
    return false
  end

  moves_data = response["data"]["move"]
  @prompt.say("Successfully fetched #{moves_data.length} moves.", color: :green)

  # 5. Process Data
  moves_data.each do |move_datum|
    # Format: "thunder-punch" -> "Thunder Punch"
    formatted_name = move_datum["name"].split("-").map(&:capitalize).join(" ")
    
    @bar.advance(1, name: formatted_name.ljust(20))

    # Safely dig for the short effect text
    effect_text = move_datum.dig("move_effect", "move_effect_texts")&.first&.[]("short_effect")
    
    Move.create(
      name: formatted_name,
      move_type: move_datum.dig("type", "name") || "unknown",
      power: move_datum["power"] || 0,
      short_text: effect_text || "No description available"
    )
  end

  # 6. Final Status
  if Move.count > 0
    @prompt.say("\nDone! Moves Table built with #{Move.count} records.", color: :magenta)
    return true
  else
    @prompt.error("\nFailure! Database is empty after import.")
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
