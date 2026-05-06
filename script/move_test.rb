include MovesHelper

def assign_learned_by
  moves = Move.all
  moves.each do |move|
    move_datum = HTTParty.get(move.url)
    next unless move_datum.success? && move_datum.parsed_response.is_a?(Hash)

    details = move_datum.parsed_response
    if details["learned_by_pokemon"]
      details["learned_by_pokemon"].each do |ld|
        pokemon = Pokemon.find_by(name: ld["name"])
        next if pokemon.nil?

        PokemonMove.create(
          pokemon_id: pokemon.poke_id,
          move_id: move.id
        )
      end
    end
  end

  return true
end

# this takes nil params 
assign_learned_by