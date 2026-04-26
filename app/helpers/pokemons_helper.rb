require 'httparty'
require 'json'
module PokemonsHelper

  # gets pokemon data for every pokemon and creates and stores a model in the db for each one
  # DO NOT RUN without dumping the curent db 
  # TODO add uniq constraint on pokemon name to remove the above worry
def build_pkmn_from_graphql
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

  raw_data.map do |pkmn|
    
    build_pokemon_model(pkmn: {
      poke_id:        pkmn['poke_id'],
      name:           pkmn['name'],
      base_exp:       pkmn['base_exp'],
      pkmn_type:      pkmn['pokemon_v2_pokemontypes'].map { |t| t['pokemon_v2_type']['name'] }.join(', '),
      abilities:      pkmn['pokemon_v2_pokemonabilities'].map { |a| a['pokemon_v2_ability']['name'] },
      default_sprite: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{pkmn['poke_id']}.png",
    })
  end
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

end


