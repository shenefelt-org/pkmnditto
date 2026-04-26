class Pokemon < ApplicationRecord
  serialize :abilities, type: Array, default: [], coder: JSON

  scope :ordered_by_pokedex, -> { order(Arel.sql("COALESCE(poke_id, 999999)"), :name) }
end
