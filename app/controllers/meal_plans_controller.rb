class MealPlansController < ApplicationController
  def new
    @meal_plan = MealPlan.new
  end

  def create
    @meal_plan = MealPlan.new(meal_plan_params)

    if @meal_plan.save
      redirect_to root_path, notice: 'Meal plan created successfully'
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def meal_plan_params
    params.require(:meal_plan).permit(:start_date, :end_date, :servings, :dietary_preference)
  end
end
