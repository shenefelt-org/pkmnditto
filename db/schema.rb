# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_25_055917) do
  create_table "items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "flavor_text"
    t.text "generations"
    t.string "name"
    t.string "short_effect"
    t.string "sprite"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "moves", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "move_type"
    t.string "name"
    t.integer "power"
    t.string "short_text"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "pokemon", force: :cascade do |t|
    t.integer "base_experience"
    t.datetime "created_at", null: false
    t.integer "height"
    t.string "image_url"
    t.string "name", null: false
    t.integer "pokeapi_id", null: false
    t.string "primary_type"
    t.json "raw_payload"
    t.datetime "updated_at", null: false
    t.integer "weight"
    t.index ["name"], name: "index_pokemon_on_name", unique: true
    t.index ["pokeapi_id"], name: "index_pokemon_on_pokeapi_id", unique: true
    t.index ["primary_type"], name: "index_pokemon_on_primary_type"
  end

  create_table "types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "type_id"
    t.text "type_name"
    t.datetime "updated_at", null: false
  end
end
