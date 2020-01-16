class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :steamID, limit: 17
      t.string :session
      t.datetime :sessionEnd
      t.boolean :status
      t.datetime :lastTimeOnline
      t.datetime :lastActivityTime
      t.integer :rightFlags
      t.integer :karma
      t.text :posts

      t.timestamps
    end
  end
end
