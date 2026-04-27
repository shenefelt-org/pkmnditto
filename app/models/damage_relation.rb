class DamageRelation < ApplicationRecord
    attribute :half_damage_to, :string, array: true, default: [], coder: JSON
    attribute :half_damage_from, :string, array: true, default: [], coder: JSON
    attribute :double_damage_to, :string, array: true, default: [], coder: JSON
    attribute :double_damage_from, :string, array: true, default: [], coder: JSON
    attribute :no_damage_to, :string, array: true, default: [], coder: JSON
    attribute :no_damage_from, :string, array: true, default: [], coder: JSON
end
