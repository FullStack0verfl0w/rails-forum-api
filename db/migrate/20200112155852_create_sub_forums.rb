class CreateSubForums < ActiveRecord::Migration[6.0]
  def change
    create_table :sub_forums do |t|
      t.string :name, :null => false
      t.text :description, :null => false, :default => ""
      t.decimal :icon, :null => false, :default => ApplicationController::Icons[:DEFAULT]
      t.text :canView, :null => false, :default => ["all"].to_json
      t.text :threads, :null => false, :default => [].to_json

      t.timestamps
    end
  end
end
