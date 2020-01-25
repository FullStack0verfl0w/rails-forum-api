# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_17_122752) do

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "creatorSteamID", limit: 17
    t.decimal "thread", precision: 10, null: false
    t.text "content", null: false
    t.decimal "upvotes", precision: 10, default: "0", null: false
    t.decimal "downvotes", precision: 10, default: "0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "posts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.decimal "icon", precision: 10, default: "1", null: false
    t.string "creatorSteamID", limit: 17
    t.boolean "pinned", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.decimal "subforum", precision: 10, null: false
    t.decimal "upvotes", precision: 10, default: "0", null: false
    t.decimal "downvotes", precision: 10, default: "0", null: false
    t.text "comments", default: "'[]'", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sub_forums", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", default: "''", null: false
    t.decimal "icon", precision: 10, default: "1", null: false
    t.text "canView", default: "'[\"all\"]'", null: false
    t.text "threads", default: "'[]'", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.integer "rightFlags"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "steamID", limit: 17, null: false
    t.text "steamData"
    t.string "token"
    t.datetime "tokenEnd"
    t.boolean "status", default: false, null: false
    t.boolean "banned", default: false, null: false
    t.datetime "lastTimeOnline"
    t.datetime "lastActivityTime"
    t.string "userGroup", default: "user", null: false
    t.integer "karma", default: 0, null: false
    t.text "posts", default: "'[]'", null: false
    t.text "postsUpvoted", default: "'[]'", null: false
    t.text "postsDownvoted", default: "'[]'", null: false
    t.text "commentsUpvoted", default: "'[]'", null: false
    t.text "commentsDownvoted", default: "'[]'", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
