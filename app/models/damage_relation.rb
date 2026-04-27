class DamageRelation < ApplicationRecord
  serialize :half_damage_to, coder: JSON
  serialize :half_damage_from, coder: JSON
  serialize :double_damage_to, coder: JSON
  serialize :double_damage_from, coder: JSON
  serialize :no_damage_to, coder: JSON
  serialize :no_damage_from, coder: JSON
end