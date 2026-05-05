# --- SETUP AND COMPATIBILITY ---
unless defined?(Fixnum)
  Fixnum = Integer
end

unless defined?(Bignum)
  Bignum = Integer
end

require 'tty'
require 'tty-prompt'
require 'tty-progressbar'
require 'tty-table'
require "pastel"
require "httparty"
require "json"

# Assuming these are defined in your Rails environment
include PokemonsHelper
include TypesHelper
include MovesHelper

@pastel = Pastel.new 
@prompt = TTY::Prompt.new

# --- MAIN CONTROL LOGIC ---

def begin_process
  if !Pokemon.count.zero? || !Move.count.zero? || !Type.count.zero? || !DamageRelation.count.zero?
    
    message = @pastel.italic.bright_red.inverse.on_white(' WARNING: DB HAS DATA. Destroy and repopulate? (y/n) ')
    
    if @prompt.yes?(message)
      destroy_db
    else
      @prompt.say(@pastel.italic.bright_red.inverse.on_white(' Skipping Deletion '))
    end
  end

  build
end

# --- DATABASE DESTRUCTION ---

def destroy_db
  models = [Pokemon, Type, Move, DamageRelation]
  
  bar = TTY::ProgressBar.new(
    "Cleaning DB: [:bar] :item_name :percent", 
    total: models.length, 
    width: 30,
    complete: @pastel.bright_red("="),
    incomplete: @pastel.bright_green("-")
  )

  models.each do |model|
    bar.advance(item_name: model.name.ljust(20))
    model.destroy_all rescue nil
    sleep(0.1) 
  end

  bar.finish
  @prompt.ok(@pastel.bright_red('Database destruction complete..'))
  true
end

# --- BUILDING LOGIC ---

def build
  classes = [Pokemon, Move, Type]
  format = "#{@pastel.italic.bright_green('Building: :name')} :percent | ETA :eta"
  
  # total is classes + 1 for the relations step
  bar = TTY::ProgressBar.new(format, total: classes.length + 1, width: 50)

  classes.each do |model|
    bar.advance(0, name: model.name.ljust(15))

    if model.count.zero?
      case model.name
      when "Pokemon" then build_pkmn_from_graphql
      when "Move"    then build_moves_from_restapi
      when "Type"    then build_types_from_restapi
      end
    else
      @prompt.say(@pastel.bold.bright_yellow.on_black("\tSkipping #{model.name} - data exists"))
    end
    bar.advance(1)
  end

  # Handle Post-Build Relations
  bar.advance(0, name: "Relations")
  unless Move.count.zero? || Pokemon.count.zero?
    assign_learned_moves
  end
  bar.advance(1)

  status_msg = PokemonMove.count.zero? ? 'ERR: Move Relations Failed' : 'Success: Assigned Move Relations'
  @prompt.say(@pastel.bold.bright_magenta.on_black(status_msg))

  !Pokemon.count.zero? && !Move.count.zero? && !Type.count.zero?
end

# --- REFACTORED MOVES HELPER (Integrated) ---

def build_moves_from_restapi
  # PokeAPI URL with the 1000 limit
  url = "https://pokeapi.co/api/v2/move?limit=1000"
  response = HTTParty.get(url)
  
  unless response.success? && response.parsed_response.is_a?(Hash)
    @prompt.error("REST API Failure: #{response.code}")
    return false
  end
  
  moves_list = response.parsed_response["results"]
  
  moves_list.each do |move| 
    display_name = move["name"].split("-").map(&:capitalize).join(" ")
    
    # Fetch detailed move data
    move_datum = HTTParty.get(move["url"])
    
    # Safety check for 504 Gateway Timeouts
    next unless move_datum.success? && move_datum.parsed_response.is_a?(Hash)
    
    details = move_datum.parsed_response
    short_txt_node = details['effect_entries'].find { |e| e.dig('language', 'name') == 'en' }
    short_txt = short_txt_node ? short_txt_node['short_effect'] : 'No description available'

    model = Move.create(
      name: display_name,
      url: move["url"],
      move_type: details.dig('type', 'name'),
      power: details['power'] || 0,
      short_text: short_txt
    )
    
    # Optional: Associate with Pokemon if your helper logic requires it here
    if details["learned_by_pokemon"]
      details["learned_by_pokemon"].each do |ld|
        pkmn = Pokemon.find_by(name: ld["name"])
        next if pkmn.nil?
        PokemonMove.find_or_create_by(pokemon_id: pkmn.poke_id, move_id: model.id)
      end
    end

    sleep(0.05) # Rate limit safety
  end
  true
end

# --- EXECUTION ---

@prompt.say(@pastel.bold.bright_blue.on_black(' Starting Database Population Script... '))

begin_process

# --- FINAL SUMMARY TABLE ---

table_data = [
  ["Pokemon", Pokemon.count, !Pokemon.count.zero? ? @pastel.green("SUCCESS") : @pastel.red("FAILED")],
  ["Moves",   Move.count,    !Move.count.zero?    ? @pastel.green("SUCCESS") : @pastel.red("FAILED")],
  ["Types",   Type.count,    !Type.count.zero?    ? @pastel.green("SUCCESS") : @pastel.red("FAILED")],
  ["Relations", PokemonMove.count, !PokemonMove.count.zero? ? @pastel.green("SUCCESS") : @pastel.red("FAILED")]
]

table = TTY::Table.new(
  header: ["Model", "Count", "Status"],
  rows: table_data
)

puts "\n"
@prompt.say(@pastel.bold.bright_magenta("📊 BUILD SUMMARY REPORT"))

puts table.render(:unicode, padding: [0, 1]) do |renderer|
  renderer.border.separator = :each_row
end

puts "\n"