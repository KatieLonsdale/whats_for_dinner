class Recipe < ApplicationRecord
  validates :name, :data, presence: true
end
