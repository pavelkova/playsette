# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170906025218) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alembic_version", primary_key: "version_num", id: :string, limit: 32, force: :cascade do |t|
  end

  create_table "assigned_exercise", id: :serial, force: :cascade do |t|
    t.integer "order"
    t.boolean "allow_subs"
    t.integer "target_sets"
    t.integer "target_reps"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "embeddeds", force: :cascade do |t|
    t.string "source_path"
    t.string "source_service"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_embeddeds_on_user_id"
  end

  create_table "equipment", id: :serial, force: :cascade do |t|
    t.string "name", limit: 80
    t.boolean "has_weight"
  end

  create_table "exercise", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "image_url"
    t.string "image_filename"
    t.string "video_url"
    t.boolean "is_public"
    t.string "measure_by"
    t.index ["name"], name: "exercise_name_key", unique: true
  end

  create_table "exercise_log", id: :serial, force: :cascade do |t|
    t.string "equipment", limit: 80
    t.integer "sets"
    t.integer "reps"
    t.boolean "is_substitution"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id"
    t.bigint "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id"
    t.string "likeable_type"
    t.bigint "likeable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "title"
    t.string "artist"
    t.string "album"
    t.string "year"
    t.string "album_art_file_name"
    t.string "album_art_content_type"
    t.integer "album_art_file_size"
    t.datetime "album_art_updated_at"
    t.string "media_type"
    t.bigint "media_id"
    t.string "playback"
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "media_path"
    t.index ["media_type", "media_id"], name: "index_tracks_on_media_type_and_media_id"
    t.index ["user_id"], name: "index_tracks_on_user_id"
  end

  create_table "uploads", force: :cascade do |t|
    t.string "audio_file_name"
    t.string "audio_content_type"
    t.integer "audio_file_size"
    t.datetime "audio_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "{:foreign_key=>true}_id"
    t.index ["{:foreign_key=>true}_id"], name: "index_uploads_on_{:foreign_key=>true}_id"
  end

  create_table "user", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "password", limit: 255
    t.string "username", limit: 40
    t.index ["email"], name: "user_email_key", unique: true
    t.index ["username"], name: "user_username_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "remember_digest"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.text "profile_bio"
    t.boolean "admin", default: false
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "workout", id: :serial, force: :cascade do |t|
    t.string "image_url"
    t.string "image_filename"
    t.boolean "is_public"
  end

  create_table "workout_log", id: :serial, force: :cascade do |t|
  end

  add_foreign_key "comments", "users"
  add_foreign_key "embeddeds", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "tracks", "users"
end
