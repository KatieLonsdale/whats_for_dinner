class CreateMealPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :meal_plans do |t|
      t.date :start_date
      t.date :end_date
      t.integer :servings
      t.string :dietary_preference

      t.timestamps
    end
  end
end
