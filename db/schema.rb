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

ActiveRecord::Schema[8.1].define(version: 2026_01_15_204655) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "deliveries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.decimal "fuel_cost", precision: 10, scale: 2, default: "0.0"
    t.decimal "maintenance_cost", precision: 10, scale: 2, default: "0.0"
    t.decimal "other_costs", precision: 10, scale: 2, default: "0.0"
    t.decimal "route_value", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
  end

  create_table "earnings", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "notes"
    t.string "platform"
    t.string "trip_id"
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_earnings_on_date"
    t.index ["platform"], name: "index_earnings_on_platform"
  end

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "description"
    t.text "notes"
    t.datetime "updated_at", null: false
    t.string "vendor"
    t.index ["category"], name: "index_expenses_on_category"
    t.index ["date"], name: "index_expenses_on_date"
  end
end
