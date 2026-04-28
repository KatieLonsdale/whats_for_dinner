require 'rails_helper'

RSpec.describe 'MealPlans', type: :request do
  describe 'GET /meal_plans/new' do
    it 'returns a successful response' do
      get new_meal_plan_path
      expect(response).to have_http_status(:ok)
    end

    it 'renders the new template' do
      get new_meal_plan_path
      expect(response.body).to include('Create Meal Plan')
    end

    it 'includes form fields for all meal plan attributes' do
      get new_meal_plan_path
      expect(response.body).to include('Start Date')
      expect(response.body).to include('End Date')
      expect(response.body).to include('Number of Servings')
      expect(response.body).to include('Dietary Preference')
    end

    it 'includes all dietary preference options' do
      get new_meal_plan_path
      expect(response.body).to include('vegetarian')
      expect(response.body).to include('vegan')
      expect(response.body).to include('pescatarian')
      expect(response.body).to include('plant forward')
      expect(response.body).to include('gluten free')
    end
  end

  describe 'POST /meal_plans' do
    let(:valid_attributes) do
      {
        meal_plan: {
          start_date: Date.today,
          end_date: Date.today + 7.days,
          servings: 2,
          dietary_preference: 'vegetarian'
        }
      }
    end

    let(:invalid_attributes) do
      {
        meal_plan: {
          start_date: nil,
          end_date: Date.today,
          servings: 0,
          dietary_preference: 'invalid'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new MealPlan' do
        expect {
          post meal_plans_path, params: valid_attributes
        }.to change(MealPlan, :count).by(1)
      end

      it 'redirects to the root path' do
        post meal_plans_path, params: valid_attributes
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success flash message' do
        post meal_plans_path, params: valid_attributes
        expect(response).to have_http_status(:see_other)
        follow_redirect!
        expect(response.body).to include('alert-success')
        expect(response.body).to include('Meal plan created successfully')
      end

      it 'saves the meal plan with correct attributes' do
        post meal_plans_path, params: valid_attributes
        meal_plan = MealPlan.last
        expect(meal_plan.start_date).to eq(Date.today)
        expect(meal_plan.end_date).to eq(Date.today + 7.days)
        expect(meal_plan.servings).to eq(2)
        expect(meal_plan.dietary_preference).to eq('vegetarian')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new MealPlan' do
        expect {
          post meal_plans_path, params: invalid_attributes
        }.not_to change(MealPlan, :count)
      end

      it 're-renders the new template' do
        post meal_plans_path, params: invalid_attributes
        expect(response.body).to include('Create Meal Plan')
      end

      it 'returns an unprocessable content status' do
        post meal_plans_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'displays error messages' do
        post meal_plans_path, params: invalid_attributes
        expect(response.body).to include('error')
      end
    end

    context 'with missing parameters' do
      it 'does not create a meal plan when required fields are missing' do
        expect {
          post meal_plans_path, params: { meal_plan: { servings: 2 } }
        }.not_to change(MealPlan, :count)
      end

      it 're-renders the form with errors' do
        post meal_plans_path, params: { meal_plan: { servings: 2 } }
        expect(response.body).to include('error')
      end
    end

    context 'with invalid date range' do
      it 'rejects when end date is too far in the future' do
        attributes = {
          meal_plan: {
            start_date: Date.today,
            end_date: Date.today + 31.days,
            servings: 2,
            dietary_preference: 'vegetarian'
          }
        }
        expect {
          post meal_plans_path, params: attributes
        }.not_to change(MealPlan, :count)

        expect(response.body).to include('cannot be more than 30 days')
      end

      it 'rejects when end date is before start date' do
        attributes = {
          meal_plan: {
            start_date: Date.today,
            end_date: Date.today - 1.day,
            servings: 2,
            dietary_preference: 'vegetarian'
          }
        }
        expect {
          post meal_plans_path, params: attributes
        }.not_to change(MealPlan, :count)

        expect(response.body).to include('must be after or equal to start date')
      end

      it 'rejects when date range is less than 1 day' do
        attributes = {
          meal_plan: {
            start_date: Date.today,
            end_date: Date.today,
            servings: 2,
            dietary_preference: 'vegetarian'
          }
        }
        expect {
          post meal_plans_path, params: attributes
        }.not_to change(MealPlan, :count)

        expect(response.body).to include('must be at least 1 day after start date')
      end
    end

    context 'strong parameters' do
      it 'only allows whitelisted parameters' do
        attributes = {
          meal_plan: {
            start_date: Date.today,
            end_date: Date.today + 7.days,
            servings: 2,
            dietary_preference: 'vegetarian',
            admin: true,
            user_id: 999
          }
        }
        post meal_plans_path, params: attributes
        meal_plan = MealPlan.last
        expect(meal_plan).not_to have_attribute(:admin)
      end
    end
  end
end
