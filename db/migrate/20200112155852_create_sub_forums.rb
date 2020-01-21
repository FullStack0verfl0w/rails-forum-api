class CreateSubForums < ActiveRecord::Migration[6.0]
  def change
    create_table :sub_forums do |t|
      t.string :name, :null => false
      t.text :description, :null => false, :default => ""
      t.string :icon, :null => false, :default => "default"
      t.text :canView, :null => false, :default => ["all"].to_json
      t.text :posts, :null => false, :default => [""].to_json

      t.timestamps
    end
  end
end
