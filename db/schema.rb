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

ActiveRecord::Schema[8.1].define(version: 2026_04_29_221042) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "damage_relations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "double_damage_from"
    t.text "double_damage_to"
    t.text "half_damage_from"
    t.text "half_damage_to"
    t.text "no_damage_from"
    t.text "no_damage_to"
    t.integer "type_id"
    t.string "type_name"
    t.datetime "updated_at", null: false
    t.index ["type_id"], name: "index_damage_relations_on_type_id"
  end

  create_table "docs", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "permalink"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_docs_on_name", unique: true
  end

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

  create_table "move_learned_bies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "move_id", null: false
    t.integer "pokemon_id", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_move_learned_bies_on_move_id"
    t.index ["pokemon_id"], name: "index_move_learned_bies_on_pokemon_id"
  end

  create_table "move_weaknesses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "move_id", null: false
    t.integer "type_id", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_move_weaknesses_on_move_id"
    t.index ["type_id"], name: "index_move_weaknesses_on_type_id"
  end

  create_table "moves", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "move_type"
    t.string "name"
    t.integer "power"
    t.string "short_text"
    t.integer "type_id"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["type_id"], name: "index_moves_on_type_id"
  end

  create_table "pokemon_moves", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "move_id", null: false
    t.integer "pokemon_id", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_pokemon_moves_on_move_id"
    t.index ["pokemon_id"], name: "index_pokemon_moves_on_pokemon_id"
  end

  create_table "pokemons", force: :cascade do |t|
    t.text "abilities"
    t.integer "base_exp"
    t.string "cries"
    t.string "default_sprite"
    t.string "name"
    t.string "pkmn_type"
    t.integer "poke_id"
    t.index ["name"], name: "index_pokemons_on_name", unique: true
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.index ["name"], name: "index_types_on_name", unique: true
    t.index ["url"], name: "index_types_on_url", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "profile_image_url"
    t.string "sub"
    t.datetime "updated_at", null: false
    t.index ["sub"], name: "index_users_on_sub", unique: true
  end

  add_foreign_key "damage_relations", "types"
  add_foreign_key "move_learned_bies", "moves"
  add_foreign_key "move_learned_bies", "pokemons"
  add_foreign_key "move_weaknesses", "moves"
  add_foreign_key "move_weaknesses", "types"
  add_foreign_key "moves", "types"
  add_foreign_key "pokemon_moves", "moves"
  add_foreign_key "pokemon_moves", "pokemons"
end
