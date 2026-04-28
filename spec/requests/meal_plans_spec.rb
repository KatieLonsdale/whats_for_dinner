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
    let(:meal_plan_data) do
      {
        "meal_plan": [
          {
            "date": "2026-05-01",
            "meals": {
              "breakfast": { "name": "Vegetarian Omelette", "description": "Fluffy omelette with vegetables" },
              "lunch": { "name": "Quinoa Buddha Bowl", "description": "Nutritious bowl with grains and veggies" },
              "dinner": { "name": "Lentil Pasta", "description": "Pasta with lentil sauce" }
            }
          }
        ],
        "recipes": [
          {
            "meal_name": "Vegetarian Omelette",
            "serves": 2,
            "prep_time": "5 minutes",
            "cook_time": "10 minutes",
            "ingredients": [
              { "item": "eggs", "quantity": "3", "unit": "whole" },
              { "item": "bell peppers", "quantity": "1", "unit": "cup" }
            ],
            "steps": ["Beat eggs", "Cook in pan", "Add vegetables"],
            "estimated_cost_per_serving": "$2.50"
          }
        ],
        "grocery_list": {
          "estimated_total_cost": "$45.00",
          "categories": {
            "produce": [
              { "item": "bell peppers", "quantity": "2", "unit": "lbs" }
            ],
            "dairy": [
              { "item": "eggs", "quantity": "12", "unit": "whole" }
            ],
            "grains": [],
            "meat_fish": [],
            "pantry": [],
            "frozen": [],
            "other": []
          }
        }
      }
    end

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
      it 'calls the AIApiService' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan).and_return(data: meal_plan_data)

        post meal_plans_path, params: valid_attributes

        expect(AIApiService).to have_received(:new)
      end

      it 'renders the result view' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan).and_return(data: meal_plan_data)

        post meal_plans_path, params: valid_attributes

        expect(response).to render_template(:result)
      end

      it 'returns a successful response' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan).and_return(data: meal_plan_data)

        post meal_plans_path, params: valid_attributes

        expect(response).to have_http_status(:ok)
      end

      it 'displays the meal plan data' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan).and_return(data: meal_plan_data)

        post meal_plans_path, params: valid_attributes

        expect(response.body).to include('Your Meal Plan')
        expect(response.body).to include('Daily Meal Plan')
        expect(response.body).to include('Recipes')
        expect(response.body).to include('Grocery List')
      end

      it 'displays the generated meals' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan).and_return(data: meal_plan_data)

        post meal_plans_path, params: valid_attributes

        expect(response.body).to include('Vegetarian Omelette')
        expect(response.body).to include('Quinoa Buddha Bowl')
        expect(response.body).to include('Lentil Pasta')
      end

      it 'displays recipes with details' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan).and_return(data: meal_plan_data)

        post meal_plans_path, params: valid_attributes

        expect(response.body).to include('eggs')
        expect(response.body).to include('bell peppers')
        expect(response.body).to include('Beat eggs')
      end

      it 'displays grocery list with categories' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan).and_return(data: meal_plan_data)

        post meal_plans_path, params: valid_attributes

        expect(response.body).to include('Produce')
        expect(response.body).to include('Dairy')
        expect(response.body).to include('$45.00')
      end

      it 'passes correct parameters to AIApiService' do
        service_instance = instance_double(AIApiService)
        allow(AIApiService).to receive(:new).and_return(service_instance)
        allow(service_instance).to receive(:create_meal_plan).and_return(data: meal_plan_data)

        post meal_plans_path, params: valid_attributes

        expect(AIApiService).to have_received(:new).with(
          hash_including(
            start_date: Date.today,
            end_date: Date.today + 7.days,
            num_people: 2,
            dietary_preferences: 'vegetarian'
          )
        )
      end
    end

    context 'with invalid form parameters' do
      it 'does not call AIApiService' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan)

        post meal_plans_path, params: invalid_attributes

        expect(AIApiService).not_to have_received(:new)
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

    context 'with API errors' do
      it 'handles API errors gracefully' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan)
          .and_return(error: 'API error: Rate limit exceeded')

        post meal_plans_path, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('error')
        expect(response.body).to include('API error: Rate limit exceeded')
      end

      it 'handles JSON parse errors' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan)
          .and_return(error: 'Claude returned invalid JSON: Unexpected token')

        post meal_plans_path, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Claude returned invalid JSON')
      end

      it 're-renders the form on API error' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan)
          .and_return(error: 'API error: Service unavailable')

        post meal_plans_path, params: valid_attributes

        expect(response.body).to include('Create Meal Plan')
      end
    end

    context 'with missing parameters' do
      it 'does not call AIApiService when required fields are missing' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan)

        post meal_plans_path, params: { meal_plan: { servings: 2 } }

        expect(AIApiService).not_to have_received(:new)
      end

      it 're-renders the form with errors' do
        post meal_plans_path, params: { meal_plan: { servings: 2 } }

        expect(response.body).to include('error')
      end
    end

    context 'with invalid date range' do
      it 'rejects when end date is too far in the future' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan)

        attributes = {
          meal_plan: {
            start_date: Date.today,
            end_date: Date.today + 31.days,
            servings: 2,
            dietary_preference: 'vegetarian'
          }
        }

        post meal_plans_path, params: attributes

        expect(AIApiService).not_to have_received(:new)
        expect(response.body).to include('cannot be more than 30 days')
      end

      it 'rejects when end date is before start date' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan)

        attributes = {
          meal_plan: {
            start_date: Date.today,
            end_date: Date.today - 1.day,
            servings: 2,
            dietary_preference: 'vegetarian'
          }
        }

        post meal_plans_path, params: attributes

        expect(AIApiService).not_to have_received(:new)
        expect(response.body).to include('must be after or equal to start date')
      end

      it 'rejects when date range is less than 1 day' do
        allow(AIApiService).to receive_message_chain(:new, :create_meal_plan)

        attributes = {
          meal_plan: {
            start_date: Date.today,
            end_date: Date.today,
            servings: 2,
            dietary_preference: 'vegetarian'
          }
        }

        post meal_plans_path, params: attributes

        expect(AIApiService).not_to have_received(:new)
        expect(response.body).to include('must be at least 1 day after start date')
      end
    end
  end
end
