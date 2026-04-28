class Pokemon < ApplicationRecord
  serialize :abilities, type: Array, default: [], coder: JSON
  searialize :cries, type: Array, default: [], coder: JSON
  has_many :pokemon_moves
  has_many :moves, through: :pokemon_moves # define m:m relationship
  has_many :types
end
