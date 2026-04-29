class Recipe < ApplicationRecord
  belongs_to :user

  validates :name, :data, :user_id, presence: true
end
