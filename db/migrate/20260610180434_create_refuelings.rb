class CreateRefuelings < ActiveRecord::Migration[8.1]
  def change
    create_table :refuelings do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :expense, null: true, foreign_key: true
      t.date :date, null: false
      t.string :vendor
      t.decimal :liters, precision: 6, scale: 2, null: false
      t.decimal :price_per_liter, precision: 6, scale: 3
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.integer :odometer_km, null: false
      t.boolean :full_tank, default: true, null: false

      t.timestamps
    end

    add_index :refuelings, [:vehicle_id, :date]
  end
end
