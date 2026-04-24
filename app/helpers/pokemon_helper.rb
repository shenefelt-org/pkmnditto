require 'httparty'
require 'json'
require 'dotenv-rails'
Dotenv.load
# DEFAULT pkmn will always be jynx if no param is passed in 
module PokemonHelper
  $def_pkmn_request = HTTParty.get("#{ENV['DEFAULT_PKMN_URL']}")
  $def_pkmn_name = "#{ENV['DEFAULT_PKMN']}"

  # helper function to validate HTTParty return responses for validity 
  def validate_response(response)
    return nil if response.blank? || response.empty? || response.success? != 200 || response.body.parsed_response.empty?
  end

  # get all pokemon types with type url endpoints
  def get_types
    type_chain = HTTParty.get(ENV['TYPE_ENDPOINT'])
    return nil if type_chain.blank?

    return type_chain["results"].map { |type| { type["name"] => type["url"] } }
  end

  # get all pokemon with their url endpoints
  def get_all_pokemon
    list = HTTParty.get(ENV['PKMN_ENDPOINT'])
    validate_response(list)
    poke_chain = list.parsed_response

    return poke_chain["results"].map { |poke| { poke["name"] => poke["url"] } }
  end

  # get a pokemon by name, default is jynx
  def get_pokemon_by_name(name = $def_pkmn_name)

    response = HTTParty.get("#{ENV['PKMN_ENDPOINT']}#{name.downcase}")
    return response.parsed_response unless validate_response(response)
    
  end

  # by default get info for tangela note lets make these build pokemon objects for the application
  def get_pokemon_by_poke_id(id = ENV['DEFAULT_PKMN_ID'])
    response = HTTParty.get("#{ENV['PKMN_ENDPOINT']}#{id}")
    return response.parsed_response unless validate_response(response) 

  end

  # Get all pokemon by a given type. default ice-psychic
  def get_pokemon_by_type(type = ENV['DEFAULT_PKMN_TYPE'])
    type_response = HTTParty.get("#{ENV['TYPE_ENDPOINT']}#{type.downcase}")
    return nil if validate_response(type_response).nil?
    type_chain = type_response.parsed_response

    return type_chain['pokemon'].map { |poke| poke['pokemon']['name'] }
  end


  # get a pokemons abiiltes
  def get_pokemon_abilities(pokemon = $def_pkmn_request)
    pokemon = $def_pkmn_request.parsed_response if pokemon == $def_pkmn_request
    abilities = pokemon['abilities']
    return nil if abilities.blank?

    return abilities.map { |ability| ability['ability']['name'] } 
  end

  # get all weaknesses related to a pokemon and it's type. 
  def get_pokemon_weaknesses(pokemon = $def_pkmn_request)
    $type_map = get_types if $type_map.empty?
    type_url = pokemon['types'][0]['type']['url']
    res = HTTParty.get(type_url)
    validate_response(res)
    return res['damage_relations']['take_damage_from'].map { |weakness| weakness['name'] }
  end

  # grab main pokemon sprite
  def get_pokemon_artwork(pokemon = $def_pkmn_request, sprite_choice = 'front_default')
    sprite_image_choices = ['front_default', 'front_shiny', 'back_default', 'back_shiny']
    return nil unless sprite_image_choices.include?(sprite_choice)
    puts pokemon['sprites']['other']['home'][sprite_choice]
  end

  # get items a pokem is holding if there are any.
  # TODO add url mapping here to the items end point
  def get_held_items(pokemon = $def_pkmn_request)
    return pokemon.parsed_response unless validate_response(pokemon)
    return nil if pokemon['held_items'].blank? || pokemon['held_items'].empty?

    return pokemon['held_items'].map { |item| item['item']['name'] }
  end



  # parse the evolution chain of a pokemon recursilvey 
  def parse_evolutions(evolution_chain)
    evolition_map = { evolution_chain['species']['name'] => [] }
    evolution_chain['evolves_to'].each do |evolution|
      evolition_map[evolution_chain['species']['name']] << parse_evolutions(evolution)
    end
    evolition_map
  end

  # get all moves of a pokemon
  def get_pokemon_moves(pokemon = $def_pkmn_request)
    return nil if pokemon['moves'].blank? || pokemon['moves'].empty?

    return pokemon['moves'].map { |move| move['move']['name'] }
  end
  
end




