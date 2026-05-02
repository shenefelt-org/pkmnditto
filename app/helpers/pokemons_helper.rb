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
  include MovesHelper

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
    complete: pastel.bright_green("&"),
    incomplete: pastel.bright_red.on_black("*"),
    clear: false
  }

  format = "#{pastel.bright_green("Parsing :name")} [:bar] :percent "
  bar = TTY::ProgressBar.new(format, bar_options)


  raw_data.map do |pkmn|
    
     Pokemon.create(
       poke_id:        pkmn['poke_id'],
       name:           pkmn['name'],
       base_exp:       pkmn['base_exp'],
       pkmn_type:      pkmn['pokemon_v2_pokemontypes'].map { |t| t['pokemon_v2_type']['name'] }.join(', '),
       abilities:      pkmn['pokemon_v2_pokemonabilities'].map { |a| a['pokemon_v2_ability']['name'] },
       default_sprite: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{pkmn['poke_id']}.png",
     ) 

     poke_count = Pokemon.count

     prompt.say("#{pastel.cyan('No pokemon loaded')}") if poke_count.zero?


    bar.advance(1, name: pkmn['name'])
  end

  prompt.say("Getting ")
  get_pokemon_cries() unless Pokemon.count.zero?
  get_pokemon_moves() unless Pokemon.count.zero? || Move.count.zero?

  return false 

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

def get_pokemon_cries()
  pkmn = Pokemon.all 
  pkmn = build_pkmn_from_graphql() if pkmn.blank?
  return nil if pkmn.blank?

  pkmn.each_with_index do |poke, index| 
    puts "#{index} Getting #{poke.name} cries..."
    p = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{poke.id}") 

   poke.update(cries: [{
      legacy: p.dig("cries", "legacy"),
      latest: p.dig("cries", "latest")
    }])

  end
end

def get_pokemon_moves()

  build_moves_from_restapi() if Move.count.zero?
  moves = Move.all

  return if moves.nil? || Pokemon.count.zero?

  move.each do |move|
    learned_data = HTTParty.get(move.url)['learned_by_pokemon']
    next if learned_data.empty?

    learned_data.each do |ld|
      curr = Pokemon.find_by(name: ld['name'])
      curr.moves << move
    end
  end

  return true 

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

end


