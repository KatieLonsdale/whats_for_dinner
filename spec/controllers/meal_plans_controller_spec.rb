require 'rails_helper'

RSpec.describe MealPlansController, type: :controller do
  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'assigns a new MealPlan to @meal_plan' do
      get :new
      expect(assigns(:meal_plan)).to be_a_new(MealPlan)
    end

    it 'returns a successful response' do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        start_date: Date.today,
        end_date: Date.today + 7.days,
        servings: 2,
        dietary_preference: 'vegetarian'
      }
    end

    let(:invalid_attributes) do
      {
        start_date: nil,
        end_date: Date.today,
        servings: 0,
        dietary_preference: 'invalid'
      }
    end

    context 'with valid parameters' do
      it 'creates a new MealPlan' do
        expect {
          post :create, params: { meal_plan: valid_attributes }
        }.to change(MealPlan, :count).by(1)
      end

      it 'redirects to the root path' do
        post :create, params: { meal_plan: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success flash message' do
        post :create, params: { meal_plan: valid_attributes }
        expect(flash[:notice]).to eq('Meal plan created successfully')
      end

      it 'saves the meal plan with correct attributes' do
        post :create, params: { meal_plan: valid_attributes }
        meal_plan = MealPlan.last
        expect(meal_plan.start_date).to eq(valid_attributes[:start_date])
        expect(meal_plan.end_date).to eq(valid_attributes[:end_date])
        expect(meal_plan.servings).to eq(valid_attributes[:servings])
        expect(meal_plan.dietary_preference).to eq(valid_attributes[:dietary_preference])
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new MealPlan' do
        expect {
          post :create, params: { meal_plan: invalid_attributes }
        }.not_to change(MealPlan, :count)
      end

      it 're-renders the new template' do
        post :create, params: { meal_plan: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it 'returns an unprocessable entity status' do
        post :create, params: { meal_plan: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'assigns the meal plan with errors to @meal_plan' do
        post :create, params: { meal_plan: invalid_attributes }
        expect(assigns(:meal_plan)).to be_a(MealPlan)
        expect(assigns(:meal_plan).errors).not_to be_empty
      end
    end

    context 'with missing parameters' do
      it 'does not create a meal plan when required fields are missing' do
        expect {
          post :create, params: { meal_plan: { servings: 2 } }
        }.not_to change(MealPlan, :count)
      end

      it 're-renders the form with errors' do
        post :create, params: { meal_plan: { servings: 2 } }
        expect(response).to render_template(:new)
        expect(assigns(:meal_plan).errors).not_to be_empty
      end
    end

    context 'with invalid date range' do
      it 'rejects when end date is too far in the future' do
        attributes = valid_attributes.merge(end_date: Date.today + 31.days)
        expect {
          post :create, params: { meal_plan: attributes }
        }.not_to change(MealPlan, :count)

        expect(assigns(:meal_plan).errors[:end_date]).to be_present
      end

      it 'rejects when end date is before start date' do
        attributes = valid_attributes.merge(end_date: Date.today - 1.day)
        expect {
          post :create, params: { meal_plan: attributes }
        }.not_to change(MealPlan, :count)

        expect(assigns(:meal_plan).errors[:end_date]).to be_present
      end
    end

    context 'strong parameters' do
      it 'only allows whitelisted parameters' do
        params = {
          meal_plan: valid_attributes.merge(admin: true, user_id: 999)
        }
        post :create, params: params
        meal_plan = MealPlan.last
        expect(meal_plan).not_to respond_to(:admin)
        expect(meal_plan).not_to respond_to(:user_id)
      end
    end
  end
end
