class CreateMaintenances < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenances do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :category, default: 4, null: false
      t.integer :due_at_km
      t.date :due_at_date
      t.decimal :estimated_cost, precision: 10, scale: 2
      t.boolean :completed, default: false, null: false

      t.timestamps
    end

    add_index :maintenances, [:vehicle_id, :completed]
  end
end
