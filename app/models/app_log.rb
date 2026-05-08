class AppLog < ApplicationRecord
  belongs_to :user, optional: true
end
