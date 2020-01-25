class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :creatorSteamID, limit: 17
      t.decimal :thread, :null => false
      t.text :content, :null => false
      t.decimal :upvotes, :null => false, :default => 0
      t.decimal :downvotes, :null => false, :default => 0

      t.timestamps
    end
  end
end
