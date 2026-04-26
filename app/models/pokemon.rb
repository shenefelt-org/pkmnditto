class Pokemon < ApplicationRecord
  serialize :abilities, type: Array, default: [], coder: JSON
  :has_many types, moves
end
