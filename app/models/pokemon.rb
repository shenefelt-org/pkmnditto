class Pokemon < ApplicationRecord
  serialize :abilities, type: Array, default: [], coder: JSON

<<<<<<< HEAD
=======
  scope :ordered_by_pokedex, -> { order(Arel.sql("COALESCE(poke_id, 999999)"), :name) }
>>>>>>> 744728111aa2b8c006b8e9c15495daa530d6347e
end
