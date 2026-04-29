class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.string :name, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end

    add_index :recipes, :name
  end
end
