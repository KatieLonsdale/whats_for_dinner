class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    # Try to find or create user by name
    @user = User.find_or_create_by(name: user_params[:name])

    if @user
      redirect_to new_meal_plan_path(user_id: @user.id), notice: "User #{@user.name} loaded successfully"
    else
      @user = User.new
      @user.errors.add(:base, "Unable to create or find user")
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
