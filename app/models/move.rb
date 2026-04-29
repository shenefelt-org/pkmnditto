class Move < ApplicationRecord
    belongs_to :type
    has_many :pokemon_moves
    has_many :learned_by, through: :pokemon_moves, source: :pokemon # define m:m relationship
    has_one :damage, through: :type, source: :damage_relation # define m:m relationship

end
