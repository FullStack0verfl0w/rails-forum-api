class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title, :null => false
      t.text :content, :null => false
      t.decimal :icon, :null => false, :default => ApplicationController::Icons[:DEFAULT]
      t.string :creatorSteamID, limit: 17
      t.boolean :pinned, :null => false, :default => false
      t.boolean :closed, :null => false, :default => false
      t.decimal :subforum, :null => false
      t.decimal :upvotes, :null => false, :default => 0
      t.decimal :downvotes, :null => false, :default => 0
      t.text :comments, :null => false, :default => [].to_json

      t.timestamps
    end
  end
end
