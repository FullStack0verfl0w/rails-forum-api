class CreateSubForums < ActiveRecord::Migration[6.0]
  def change
    create_table :sub_forums do |t|
      t.string :name
      t.text :description
      t.string :icon
      t.text :canView
      t.text :posts

      t.timestamps
    end
  end
end
