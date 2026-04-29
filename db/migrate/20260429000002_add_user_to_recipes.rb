class AddUserToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :user_id, :bigint, null: false
    add_index :recipes, :user_id
    add_foreign_key :recipes, :users
  end
end
