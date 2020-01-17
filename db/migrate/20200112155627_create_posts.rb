class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.string :icon
      t.string :creatorSteamID, limit: 17
      t.decimal :upvotes
      t.decimal :downvotes
      t.text :comments

      t.timestamps
    end
  end
end
