unless defined?(Fixnum)
  Fixnum = Integer
end

unless defined?(Bignum)
  Bignum = Integer
end

require 'httparty'
require 'json'
require 'tty'
require 'tty-prompt'
require 'tty-progressbar'
require 'pastel'
module PokemonsHelper
  include PokemonsHelper
  @endpoint = "https://pokeapi.co/api/v2/pokemon/"

  # gets pokemon data for every pokemon and creates and stores a model in the db for each one
  # DO NOT RUN without dumping the curent db 
  # TODO add uniq constraint on pokemon name to remove the above worry
def build_pkmn_from_graphql
  pastel = Pastel.new

  prompt = TTY::Prompt.new
  
  url = "https://beta.pokeapi.co/graphql/v1beta"
  
  query = <<~GQL
    query getPokemonData {
      pokemon_v2_pokemon {
        poke_id: id
        name
        base_exp: base_experience
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonabilities { pokemon_v2_ability { name } }
        pokemon_v2_pokemonsprites { sprites }
      }
    }
  GQL

  response = HTTParty.post(url, headers: { 'Content-Type' => 'application/json' }, body: { query: query }.to_json)
  
  return nil unless response.success?
  
  raw_data = response.parsed_response['data']['pokemon_v2_pokemon']

  bar_options = {
    total: raw_data.length,
    width: 40,
    complete: pastel.bright_green("="),
    incomplete: pastel.bright_red.on_black("-"),
    clear: false
  }

  format = "#{pastel.bold.bright_green("Creating :name")} [:bar] "
  bar = TTY::ProgressBar.new(format, bar_options)


  raw_data.map do |pkmn|
    bar.advance(name: pkmn['name'].ljust(20))
    sleep(0.2)
    
     pkmn = Pokemon.create(
      # --- FIX: These were outside the loop in your snippet ---
       poke_id:        pkmn['poke_id'],
       name:           pkmn['name'],
       base_exp:       pkmn['base_exp'],
       pkmn_type:      pkmn['pokemon_v2_pokemontypes'].map { |t| t['pokemon_v2_type']['name'] }.join(', '),
       abilities:      pkmn['pokemon_v2_pokemonabilities'].map { |a| a['pokemon_v2_ability']['name'] },
       default_sprite: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{pkmn['poke_id']}.png",
     ) 

    assign_learned_moves(pkmn: pkmn)


  end

  return false if Pokemon.count.zero?
  cries_format = "#{pastel.bold.bright_magenta('Gathering Pokemon Cries')}"
  prompt.say(cries_format)
  get_pokemon_cries() ? prompt.say("#{pastel.bold.bright_green('Success! Pokemon Cries Gathered!')}") : prompt.say("#{pastel.bold.bright_red('Failed to gather cries')}")

end
    
# build a pokemon model for the db from the graph ql call above
# this is used to build a model for ALL pokemon in the api.
def build_pokemon_model(pkmn: nil)
  return nil if pkmn.nil?
  return Pokemon.create(
    poke_id: pkmn[:poke_id],
    name: pkmn[:name],
    base_exp: pkmn[:base_exp],
    pkmn_type: pkmn[:pkmn_type],
    abilities: pkmn[:abilities],
    default_sprite: pkmn[:default_sprite]
  )
end

def get_pokemon_cries
  pastel = Pastel.new
  prompt = TTY::Prompt.new

  pokemon_list = Pokemon.all
  
  bar = TTY::ProgressBar.new(
    "Gathering cries: [:bar] :pokemon_name :percent",
    total: pokemon_list.count,
    width: 30
  )

  pokemon_list.each_with_index do |pokemon, index|
    bar.advance(pokemon_name: pokemon.name.ljust(20))

    url = "https://pokeapi.co/api/v2/pokemon/#{pokemon.name.downcase}"
    response = HTTParty.get(url)

    # CHECK IF RESPONSE IS SUCCESSFUL AND IS A HASH
    unless response.success? && response.parsed_response.is_a?(Hash)
      prompt.warn(" Skipping #{pokemon.name}: API returned #{response.code}")
      next
    end

    details = response.parsed_response
    cry_url = details.dig('cries', 'latest')

    if cry_url.present?
      pokemon.update(cry_url: cry_url)
    end

    sleep(0.05)
  end

  bar.finish
  prompt.ok(pastel.bright_cyan('Pokemon cries gathered!'))
end




# Find a pokemons damage relations (this will be done by active record in the application)
def find_damage_relations(pkmn: nil)
  return nil if pkmn.nil?
  types = pkmn.pkmn_type.split(', ')
  damage_relations = []
  types.each do |type|
    damage_relations.push(DamageRelation.find_by(type: type))
  end

  return damage_relations
end


def assign_learned_moves(pkmn: nil)
  return nil if pkmn.nil?

  # 1. Fetch moves for the specific pokemon
  response = HTTParty.get("#{endpoint}#{pkmn.name.downcase}")
  return nil if response.blank? || response["moves"].blank?

  response["moves"].each do |move_data|
    name = move_data["move"]["name"] # Fixed typo: removed extra '
    url = move_data["move"]["url"]

    # 2. Fetch detailed move data FIRST so we have power, type, etc.
    move_details = HTTParty.get(url)
    next unless move_details.success?

    # 3. Parse details for the Move record
    short_txt_node = move_details["effect_entries"].find { |e| e["language"]["name"] == "en" }
    short_txt = short_txt_node ? short_txt_node["short_effect"] : "ERR NO DATA"

    # Find or create the Type
    type_name = move_details["type"]["name"]
    move_type = Type.find_or_create_by(name: type_name)

    # 4. Find or create the Move with all data present
    move = Move.find_or_create_by(name: name) do |m|
      m.url = url
      m.move_type = type_name
      m.power = move_details["power"] || "data not available"
      m.short_text = short_txt
      m.type_id = move_type&.id || 1
    end

    # 5. Create the association between this Pokemon and the Move
    # (Assuming a join table like PokemonMove)
    PokemonMove.find_or_create_by(pokemon_id: pkmn.id, move_id: move.id)
  end
end



end


