require_relative '../services/ai_api_service'

class MealPlansController < ApplicationController
  def new
    @user_id = params[:user_id]
    @meal_plan = MealPlan.new
  end

  def create
    @user_id = meal_plan_params[:user_id]
    @meal_plan = MealPlan.new(meal_plan_params.except(:user_id))
    @meal_plan.user_id = @user_id

    # Validate the meal plan params (form validation)
    unless @meal_plan.valid?
      return render :new, status: :unprocessable_content
    end

    # Call AI service to generate meal plan
    service_params = {
      start_date: @meal_plan.start_date,
      end_date: @meal_plan.end_date,
      num_people: @meal_plan.servings,
      dietary_preferences: @meal_plan.dietary_preference
    }

    service = AIApiService.new(service_params)
    result = service.create_meal_plan

    if result[:error].present?
      @meal_plan.errors.add(:base, result[:error])
      return render :new, status: :unprocessable_content
    end

    Rails.logger.info("Full API response: #{result[:data].inspect}")

    # Save the meal plan to the database
    unless @meal_plan.save
      @meal_plan.errors.add(:base, "Failed to save meal plan")
      return render :new, status: :unprocessable_content
    end

    # Save each recipe from the response
    Rails.logger.info("Total recipes to save: #{result[:data]['recipes']&.length || 0}")
    Rails.logger.info("Recipe data structure: #{result[:data]['recipes']&.first.inspect}")

    begin
      result[:data]['recipes']&.each do |recipe_data|
        Recipe.create!(
          name: recipe_data['meal_name'],
          data: recipe_data,
          user_id: @user_id
        )
      end
    rescue StandardError => e
      Rails.logger.error("Recipe creation failed: #{e.message}")
      Rails.logger.error("Recipes data: #{result[:data]['recipes'].inspect}")
      @meal_plan.errors.add(:base, "Failed to save recipes: #{e.message}")
      return render :new, status: :unprocessable_content
    end

    # Render the result view with the generated meal plan
    @meal_plan_data = result[:data]
    render :result
  end

  private

  def meal_plan_params
    params.require(:meal_plan).permit(:start_date, :end_date, :servings, :dietary_preference, :user_id)
  end
end
