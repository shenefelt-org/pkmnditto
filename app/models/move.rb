class Move < ApplicationRecord
    has_many :pokemon_moves
    has_many :pokemons, through: :pokemon_moves # define m:m relationship
end
