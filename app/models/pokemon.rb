class Pokemon < ApplicationRecord
  serialize :abilities, type: Array, default: [], coder: JSON
  has_many :moves
  has_many :types
end
