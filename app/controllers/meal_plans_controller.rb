require_relative '../services/ai_api_service'

class MealPlansController < ApplicationController
  def new
    @meal_plan = MealPlan.new
  end

  def create
    @meal_plan = MealPlan.new(meal_plan_params)

    # Validate the meal plan params (form validation)
    unless @meal_plan.valid?
      return render :new, status: :unprocessable_content
    end

    # Map form params to AIApiService params
    service_params = {
      start_date: @meal_plan.start_date,
      end_date: @meal_plan.end_date,
      num_people: @meal_plan.servings,
      dietary_preferences: @meal_plan.dietary_preference
    }

    # Call AI service to generate meal plan
    service = AIApiService.new(service_params)
    result = service.create_meal_plan

    if result[:error].present?
      @meal_plan.errors.add(:base, result[:error])
      return render :new, status: :unprocessable_content
    end

    # Save each recipe from the response
    result[:data][:recipes]&.each do |recipe_data|
      Recipe.create(
        name: recipe_data[:meal_name],
        data: recipe_data
      )
    end

    # Render the result view with the generated meal plan
    @meal_plan_data = result[:data]
    render :result
  end

  private

  def meal_plan_params
    params.require(:meal_plan).permit(:start_date, :end_date, :servings, :dietary_preference)
  end
end
