class MealPlan < ApplicationRecord
  belongs_to :user

  DIETARY_PREFERENCES = [
    'none',
    'vegetarian',
    'vegan',
    'pescatarian',
    'plant forward',
    'gluten free'
  ].freeze

  validates :start_date, :end_date, :servings, :dietary_preference, presence: true
  validates :servings, numericality: { only_integer: true, greater_than: 0 }
  validates :dietary_preference, inclusion: { in: DIETARY_PREFERENCES }
  validate :date_range_valid

  private

  def date_range_valid
    return if start_date.blank? || end_date.blank?

    if start_date > end_date
      errors.add(:end_date, "must be after or equal to start date")
    elsif (end_date - start_date).to_i < 1
      errors.add(:end_date, "must be at least 1 day after start date")
    elsif (end_date - start_date).to_i > 30
      errors.add(:end_date, "cannot be more than 30 days after start date")
    end
  end
end
