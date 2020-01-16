class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :creatorSteamID, limit: 17
      t.text :content
      t.decimal :upvotes
      t.decimal :downvotes

      t.timestamps
    end
  end
end
