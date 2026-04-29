class Type < ApplicationRecord
  has_many :moves
  has_many :damage_relations
end
