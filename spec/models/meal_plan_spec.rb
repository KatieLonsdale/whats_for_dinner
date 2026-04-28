require 'rails_helper'

RSpec.describe MealPlan, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:servings) }
    it { is_expected.to validate_presence_of(:dietary_preference) }

    it { is_expected.to validate_numericality_of(:servings).only_integer.is_greater_than(0) }

    it { is_expected.to validate_inclusion_of(:dietary_preference).in_array(MealPlan::DIETARY_PREFERENCES) }
  end

  describe 'date range validations' do
    let(:valid_attributes) do
      {
        start_date: Date.today,
        end_date: Date.today + 5.days,
        servings: 2,
        dietary_preference: 'vegetarian'
      }
    end

    context 'with valid date range' do
      it 'allows 1 day range' do
        meal_plan = MealPlan.new(valid_attributes.merge(end_date: Date.today + 1.day))
        expect(meal_plan).to be_valid
      end

      it 'allows 30 day range' do
        meal_plan = MealPlan.new(valid_attributes.merge(end_date: Date.today + 30.days))
        expect(meal_plan).to be_valid
      end

      it 'allows 15 day range' do
        meal_plan = MealPlan.new(valid_attributes)
        expect(meal_plan).to be_valid
      end
    end

    context 'with invalid date range' do
      it 'rejects when end date is before start date' do
        meal_plan = MealPlan.new(valid_attributes.merge(end_date: Date.today - 1.day))
        expect(meal_plan).not_to be_valid
        expect(meal_plan.errors[:end_date]).to include('must be after or equal to start date')
      end

      it 'rejects when end date is same as start date (less than 1 day)' do
        meal_plan = MealPlan.new(valid_attributes.merge(end_date: Date.today))
        expect(meal_plan).not_to be_valid
        expect(meal_plan.errors[:end_date]).to include('must be at least 1 day after start date')
      end

      it 'rejects when range exceeds 30 days' do
        meal_plan = MealPlan.new(valid_attributes.merge(end_date: Date.today + 31.days))
        expect(meal_plan).not_to be_valid
        expect(meal_plan.errors[:end_date]).to include('cannot be more than 30 days after start date')
      end
    end

    context 'with missing dates' do
      it 'does not validate date range when start_date is blank' do
        meal_plan = MealPlan.new(valid_attributes.merge(start_date: nil))
        expect(meal_plan).not_to be_valid
        expect(meal_plan.errors[:start_date]).to be_present
      end

      it 'does not validate date range when end_date is blank' do
        meal_plan = MealPlan.new(valid_attributes.merge(end_date: nil))
        expect(meal_plan).not_to be_valid
        expect(meal_plan.errors[:end_date]).to be_present
      end
    end
  end

  describe 'dietary preferences' do
    it 'has all required dietary preferences' do
      expect(MealPlan::DIETARY_PREFERENCES).to include(
        'vegetarian',
        'vegan',
        'pescatarian',
        'plant forward',
        'gluten free'
      )
    end
  end

  describe 'creation' do
    let(:valid_attributes) do
      {
        start_date: Date.today,
        end_date: Date.today + 7.days,
        servings: 4,
        dietary_preference: 'vegan'
      }
    end

    it 'creates a meal plan with valid attributes' do
      expect { MealPlan.create!(valid_attributes) }.to change(MealPlan, :count).by(1)
    end

    it 'persists all attributes' do
      meal_plan = MealPlan.create!(valid_attributes)
      expect(meal_plan.start_date).to eq(Date.today)
      expect(meal_plan.end_date).to eq(Date.today + 7.days)
      expect(meal_plan.servings).to eq(4)
      expect(meal_plan.dietary_preference).to eq('vegan')
    end
  end
end
