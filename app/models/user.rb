class User < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :meal_plans, dependent: :destroy
end
