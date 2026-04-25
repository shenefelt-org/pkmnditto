require 'httparty'
require 'json'
module PokemonsHelper
  $default_pokemon = HTTParty.get('https://pokeapi.co/api/v2/pokemon/jynx').parsed_response
  $default_pokemon_id = 124 # pokedex id for jynx


def get_all_pokemon_graphql
  url = "https://beta.pokeapi.co/graphql/v1beta"

  # We set a high limit to ensure we get every generation
  query = <<~GQL
    query getAllPokemon {
      pokemon_v2_pokemon(limit: 2000) {
        id
        name
        pokemon_v2_pokemontypes {
          pokemon_v2_type {
            name
          }
        }
      }
    }
  GQL

  response = HTTParty.post(
    url,
    headers: { 'Content-Type' => 'application/json' },
    body: { query: query }.to_json
  )

  if response.success?
    # Access the array of pokemon
    response.parsed_response['data']['pokemon_v2_pokemon']
  else
    puts "Error: #{response.code}"
    nil
  end
end

def build_pokemon_node(pokemon_url: nil)
  return nil if pokemon_url.nil?
end

  # get a pokemon by name we will use tangela as the default if no param
  def get_pokemon_by_name(name = "tangela")
    puts "You asked for #{name}" unless name == "tangela" 
    puts "No name provided, defaulting to ur mom" if name == "tangela"
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{name.downcase}")
    p_data = response.parsed_response #httparty alows us to get the parsed response as a ruby hash.

    
    return p_data unless p_data.blank? 

    
  end

  # by default get info for tangela note lets make these build pokemon objects for the application
  def get_pokemon_by_poke_id(id = $default_pokemon_id)
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{id}")
    p_data = response.parsed_response
    return p_data if !p_data.empty? 

    puts "No pokemon found with id #{id}"
    nil

  end

  def get_pokemon_by_type(type = 'fairy')
    type_response = HTTParty.get("https://pokeapi.co/api/v2/type/#{type.downcase}")

    return type_response.parsed_response unless type_response.empty? || type_response.blank?

    nil

  end

  def get_pokemon_names_by_type(type = 'fairy')
    type_response = get_pokemon_by_type(type)
    return nil if type_response.blank?
    
    return type_response['pokemon'].map { |p| p['pokemon']['name'] }
  end


  # get a pokemons abiiltes
  def get_pokemon_abilities(pokemon = $default_pokemon)
    abilities = pokemon['abilities']
    return nil if abilities.blank?

    return abilities.map { |ability| ability['ability']['name'] } 
  end


  def get_pokemon_weaknesses(pokemon = $default_pokemon)
    $type_map = get_types if $type_map.empty?
    type_url = pokemon['types'][0]['type']['url']
    res = HTTParty.get(type_url)
    return nil if res.blank? || res['damage_relations'].blank?
    return res['damage_relations']['take_damage_from'].map { |weakness| weakness['name'] }
  end

  # grab main pokemon sprite
  def get_pokemon_artwork(pokemon = $default_pokemon, sprite_choice = 'front_default')
    sprite_image_choices = ['front_default', 'front_shiny', 'back_default', 'back_shiny']
    return nil unless sprite_image_choices.include?(sprite_choice)
    puts pokemon['sprites']['other']['home'][sprite_choice]
  end

  # get items a pokem is holding if there are any.
  def get_held_items(pokemon = $default_pokemon)
    return nil if pokemon['held_items'].blank? || pokemon['held_items'].empty?

    return pokemon['held_items'].map { |item| item['item']['name'] }
  end

  # get the evolustion chain for a given pokemon 
  def get_pokemon_evolution_chain(pokemon = $default_pokemon)
    evolution_chain_url = pokemon['species']['url']
    evolution_chain_res = HTTParty.get(evolution_chain_url)
    return nil if evolution_chain_res.blank? || evolution_chain_res.empty?
    
    pkmn_evolution_chain = evolution_chain_res['evolution_chain']['url']
    chain_response = HTTParty.get(pkmn_evolution_chain)
    return nil if chain_response.blank?
    # Parse the evolution chain starting from the root and return the evolution map
    parse_evolutions(chain_response['chain'])
  end

  def parse_evolutions(evolution_chain)
    evolition_map = { evolution_chain['species']['name'] => [] }
    evolution_chain['evolves_to'].each do |evolution|
      evolition_map[evolution_chain['species']['name']] << parse_evolutions(evolution)
    end
    evolition_map
  end
end


=begin
run all methods as test with the default pokemon (jynx)
no param needed as default pokemon is passed in as def
=end


