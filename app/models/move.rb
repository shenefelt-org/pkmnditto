class Move < ApplicationRecord
    belongs_to :type
    has_many :pokemon_moves
    has_many :learned_by, through: :pokemon_moves, source: :pokemon # define m:m relationship
    has_many :weaknesses, through: :move_weaknesses, source: :type # define m:m relationship
    has_many :damage_relations, through: :type, source: :damage_relations # define m:m relationship

end
