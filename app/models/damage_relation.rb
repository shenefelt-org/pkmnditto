class DamageRelation < ApplicationRecord
    serialize :half_damage_to, :string, array: true, default: [], coder: JSON
    serialize :half_damage_from, :string, array: true, default: [], coder: JSON
    serialize :double_damage_to, :string, array: true, default: [], coder: JSON
    serialize :double_damage_from, :string, array: true, default: [], coder: JSON
    serialize :no_damage_to, :string, array: true, default: [], coder: JSON
    serialize :no_damage_from, :string, array: true, default: [], coder: JSON
end
