class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :steamID, limit: 17
      t.text :steamData
      t.string :token
      t.datetime :tokenEnd
      t.boolean :status
      t.boolean :banned
      t.datetime :lastTimeOnline
      t.datetime :lastActivityTime
      t.string :userGroup
      t.integer :karma
      t.text :posts

      t.timestamps
    end
  end
end
