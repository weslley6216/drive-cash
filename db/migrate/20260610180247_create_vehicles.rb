class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :brand, null: false
      t.string :vehicle_model, null: false
      t.integer :year, null: false
      t.string :license_plate
      t.integer :odometer_km, default: 0, null: false

      t.timestamps
    end
  end
end
