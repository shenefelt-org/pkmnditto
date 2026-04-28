class MoveWeakness < ApplicationRecord
  belongs_to :move
  belongs_to :type
  has_many :moves, through: :moves
end
