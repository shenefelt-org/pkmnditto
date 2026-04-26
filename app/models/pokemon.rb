class Pokemon < ApplicationRecord
  serialize :abilities, type: Array, default: [], coder: JSON

end
