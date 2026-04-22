require 'httparty'
require 'json'
module PokemonsHelper
  $default_pokemon = HTTParty.get('https://pokeapi.co/api/v2/pokemon/jynx')
  $default_pokemon_id = 124 # pokedex id for jynx
  $type_map = {}

  def get_types
    

    res = HTTParty.get($type_endpoint)
    return nil if res.blank?

    res["results"].each do |type|
      $type_map[type["name"]] = type["url"]
    end

    type_map
  end

  def get_all_pokemon
    poke_map = {}
    res = HTTParty.get($pokemon_all_endpoint)

    res["results"].each do |p|
      name = p["name"]
      url = p["url"]
      poke_map[p['name']] = p['url']
    end

    poke_map
  end

  # get a pokemon by name we will use tangela as the default if no param
  def get_pokemon_by_name(name = "tangela")
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{name.downcase}")
    p_data = response.parsed_response #httparty alows us to get the parsed response as a ruby hash.
    return nil if pdata.blank?

    p_data
  end

  # by default get info for tangela note lets make these build pokemon objects for the application
  def get_pokemon_by_poke_id(id = $default_pokemon_id)
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{id}")
    p_data = response.parsed_response
    return nil if p_data.blank?

    p_data
  end

  def get_pokemon_by_type(type = 'fairy')
    res = HTTParty.get("https://pokeapi.co/api/v2/type/#{type}")

    return nil if res.blank?

    res.parsed_response
  end

  # get a pokemons abiiltes
  def get_pokemon_abilities(pokemon = $default_pokemon)
    abilities = pokemon['abilities']
    ability_name = nil

    ability_name = abilities.map { |ability| ability['ability']['name'] }

    ability_name 
  end


  def get_pokemon_weaknesses(pokemon = $default_pokemon)
    $type_map = get_types if $type_map.empty?
    type_url = pokemon['types'][0]['type']['url']
    res = HTTParty.get(type_url)
    return nil if res.blank?

    weakness_map = res['damage_relations']['take_damage_from'].map do |weakness|
      { weakness['name'] => weakness['url'] }
    end.reduce(:merge)

    puts weakness_map
  end

  # grab main pokemon sprite
  def get_pokemon_artwork(pokemon = $default_pokemon)
    puts pokemon['sprites']['other']['home']['front_default']
  end

  # get items a pokem is holding if there are any.
  def get_held_items(pokemon = $default_pokemon)
    pokemon['held_items'].each do |item|
      puts "Held item name: #{item['item']['name']}"
      puts "url: #{item['item']['url']}"
    end
  end

  # get the evolustion chain for a given pokemon 
  def get_pokemon_evolution_chain(pokemon = $default_pokemon)
    evolution_chain_url = pokemon['species']['url']
    evolution_chain_res = HTTParty.get(evolution_chain_url)
    return nil if evolution_chain_res.blank?
    
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


