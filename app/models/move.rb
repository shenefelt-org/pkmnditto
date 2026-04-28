class Move < ApplicationRecord
    has_many :pokemon_moves
    has_many :learned_by, through: :pokemon_moves, source: :pokemon # define m:m relationship
end
