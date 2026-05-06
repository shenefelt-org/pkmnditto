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

def assign_learned_moves(pkmn: nil)
    return nil if pkmn.nil?
    moves = HTTParty.get("https://pokeapi.co/api/v2/pokemon/#{pkmn.name.downcase}")
    return nil if moves.blank? || moves["moves"].blank?

    Pokemon.all.each do |pokemon|
        moves_list = moves["moves"]
        moves_list.each do |move|
            move_name = move["name"]
            next if move_name.nil?
    
            move_record = Move.find_by(name: move_name)
            next if move_record.nil?
    
            PokemonMove.find(
            pokemon_id: pokemon.poke_id,
            move_id: move_record.id
            )
        end
    end
end
# this takes nil params 
Pokemon.all.each do |p|
    assign_learned_moves(pkmn: p)
end