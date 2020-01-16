class CreateSubForums < ActiveRecord::Migration[6.0]
  def change
    create_table :sub_forums do |t|
      t.string :name
      t.text :description
      t.string :icon
      t.integer :rightFlags
      t.text :posts

      t.timestamps
    end
  end
end
