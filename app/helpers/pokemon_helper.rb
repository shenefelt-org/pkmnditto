require 'httparty'
require 'json'
module PokemonsHelper
  $default_pokemon = HTTParty.get('https://pokeapi.co/api/v2/pokemon/jynx')
  $default_pokemon_id = 124 # pokedex id for jynx

  def get_types
    type_map = {}

    res = HTTParty.get($type_endpoint)
    return nil if res.blank?

    res["results"].each do |type|
      type_map[type["name"]] = type["url"]
    end

    type_map
  end

  def get_weaknesses(pokemon = $default_pokemon)
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
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/" << name.downcase)
    pokemon = response.parsed_response #httparty alows us to get the parsed response as a ruby hash.
    return nil if pokemon.blank?

    pokemon.parsed_response

  end

  # by default get info for tangela note lets make these build pokemon objects for the application
  def get_pokemon_by_poke_id(id = $default_pokemon_id)
    response = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{id}")
    pokemon = response.parsed_response
    return nil if pokemon.blank?

    pokemon.parsed_response
  end

  def get_pokemon_by_type(type = 'fairy')
    res = HTTParty.get("https://pokeapi.co/api/v2/type/#{type}")

    return nil if res.blank?

    res.parsed_response

  end

  # parser for search by name and id creates new pokemon obj
  # for each array you go into like ability items etc you loop through and output the key value name so json returns abilities {[ability: name ]} so you parse as so
  def parse_single_pokemon_results(pokemon = $default_pokemon)
    abilities = pokemon['abilities']
    puts "#{pokemon['name']} has a total of #{abilities.length}"
    abilities.each do |a|
      puts a['ability']['name']
    end
  end

  # get all known abilites for a pokemon 
  def get_pokemon_abilities(pokemon = $default_pokemon)
    pokemon['abilities'].each do |a|
      puts a['ability']['name']
    end
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
    evolution_map = {}
    evolution_chain_url = pokemon['species']['url']
    res = HTTParty.get(evolution_chain_url)
    return nil if res.blank?

    evolution_chain = res['evolution_chain']['url']
    res2 = HTTParty.get(evolution_chain)
    return nil if res2.blank?

    puts "Evolution chain for #{pokemon['name']}:"
    res2['chain']['evolves_to'].each do |evolution|
      puts evolution['species']['name']
    end
  end

end


=begin
run all methods as test with the default pokemon (jynx)
no param needed as default pokemon is passed in as def
=end


