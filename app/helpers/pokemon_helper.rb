module PokemonHelper
    $pokemon_endpoint = 'https://pokeapi.co/api/v2/pokemon/'
    $item_endpoint = 'https://pokeapi.co/api/v2/item/'

    def get_all_pokemon
        response = HTTParty.get($pokemon_endpoint)
        return response.parsed_response['results']
    end

    def get_pokemon_details(pokemon_name)
        response = HTTParty.get($pokemon_endpoint << pokemon_name)
        return nil if response.blank?

        [response.parsed_response, pokemon_image(response.parsed_response)]
    end

    def pokemon_image(pokemon_details)
        pokemon_details['sprites']['front_default']
    end

    def get_pokemon_evolution_chain(pokemon_details)
        species_response = HTTParty.get(pokemon_details['species']['url'])
        return nil if species_response.blank?
        evolution_chain_url = species_response.parsed_response['evolution_chain']['url']
        evolution_chain_response = HTTParty.get(evolution_chain_url)
        return nil if evolution_chain_response.blank?
        evolution_chain_response.parsed_response['chain']
    end

    def get_all_items
        response = HTTParty.get($item_endpoint)
        return nil if response.blank?
        response.parsed_response['results']
    end

    def get_item_details(item_name)
        response = HTTParty.get($item_endpoint << item_name)
        return nil if response.blank?
        response.parsed_response
    end


end
