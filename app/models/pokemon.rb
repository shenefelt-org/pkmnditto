class Pokemon < ApplicationRecord
  serialize :abilities, type: Array, default: []

end
