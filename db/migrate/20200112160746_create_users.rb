class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :steamID, limit: 17, :null => false
      t.text :steamData
      t.string :token
      t.datetime :tokenEnd
      t.boolean :status, :null => false, :default => false
      t.boolean :banned, :null => false, :default => false
      t.datetime :lastTimeOnline
      t.datetime :lastActivityTime
      t.string :userGroup, :null => false, :default => "user"
      t.integer :karma, :null => false, :default => 0
      t.text :posts, :null => false, :default => [].to_json

      t.timestamps
    end
  end
end
