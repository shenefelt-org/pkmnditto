class Move < ApplicationRecord
    has_many :pokemon_moves
    has_many :learned_by, through: :pokemon_moves, source: :pokemon # define m:m relationship
    has_many :weaknesses, through: :move_weaknesses, source: :type # define m:m relationship

end
