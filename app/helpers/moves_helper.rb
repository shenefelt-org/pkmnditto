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
require "pastel"
require "httparty"
require "json"

# Include your Rails/Custom Helpers
include PokemonsHelper
include TypesHelper
include MovesHelper

# Initialize shared styling (Instance variables for global access)
@pastel = Pastel.new 
@prompt = TTY::Prompt.new

# --- MAIN CONTROL LOGIC ---

def begin_process
  # Check if any data exists across core models
  if !Pokemon.count.zero? || !Move.count.zero? || !Type.count.zero? || !DamageRelation.count.zero?
    
    warning_msg = @pastel.italic.bright_red.inverse.on_white(' WARNING: DB HAS DATA. Destroy and repopulate? (y/n) ')
    
    if @prompt.yes?(warning_msg)
      destroy_db
    else
      @prompt.say(@pastel.italic.bright_red.inverse.on_white(' Skipping Deletion '))
    end
  end

  build_all
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
    model.destroy_all rescue nil # Rescue in case table doesn't exist yet
    sleep(0.1) 
  end

  bar.finish
  @prompt.ok(@pastel.bright_red('Database destruction complete.'))
end

# --- BUILDING LOGIC ---

def build_all
  # Define the sequence of build steps
  steps = [
    { name: "Types",   method: :build_types_from_restapi },
    { name: "Moves",   method: :build_moves_from_graphql },
    { name: "Pokemon", method: :build_pkmn_from_graphql }
  ]

  @bar = TTY::ProgressBar.new(
    "#{@pastel.italic.bright_green('Total Progress:')} [:bar] :percent | ETA :eta", 
    total: steps.length + 1, 
    width: 50
  )

  steps.each do |step|
    @bar.advance(0, name: step[:name])
    send(step[:method]) # Calls the specific build method
    @bar.advance(1)
  end

  # Handle Post-Build Relations
  @bar.advance(0, name: "Relations")
  unless Move.count.zero? || Pokemon.count.zero?
    assign_learned_moves
  end
  @bar.advance(1)

  status_msg = PokemonMove.count.zero? ? 'ERR: Relations Failed' : 'Success: Assigned Move Relations'
  @prompt.say(@pastel.bold.bright_magenta.on_black(status_msg))
end

# --- THE GRAPHQL MOVE BUILDER ---

def build_moves_from_graphql
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

  response = HTTParty.post(
    "https://graphql.pokeapi.co/v1beta2",
    headers: { 'Content-Type' => 'application/json' },
    body: { query: query }.to_json
  )

  if response.code != 200 || response["data"].nil?
    @prompt.error("GraphQL Fetch Failed! Status: #{response.code}")
    return false
  end

  moves_data = response["data"]["move"]

  moves_data.each do |move_datum|
    formatted_name = move_datum["name"].split("-").map(&:capitalize).join(" ")
    
    # Nested progress info for the moves specifically
    effect_text = move_datum.dig("move_effect", "move_effect_texts")&.first&.[]("short_effect")
    
    Move.create(
      name: formatted_name,
      move_type: move_datum.dig("type", "name") || "unknown",
      power: move_datum["power"] || 0,
      short_text: effect_text || "No description available"
    )
  end
  true
end

# --- EXECUTION ---

puts "\n" + @pastel.bold.bright_blue.on_black(' POKEMON DATABASE SEEDER v2026 ') + "\n\n"

begin_process

puts "\n" + "="*20 + " RESULTS " + "="*20
puts "Build Pkmn: #{!Pokemon.count.zero? ? 'SUCCESS' : 'FAILED'} (#{Pokemon.count} records)"
puts "Build Move: #{!Move.count.zero? ? 'SUCCESS' : 'FAILED'} (#{Move.count} records)"
puts "Build Type: #{!Type.count.zero? ? 'SUCCESS' : 'FAILED'} (#{Type.count} records)"
puts "="*49