class Type < ApplicationRecord
  has_many :moves
  has_one :damage_relations
end
