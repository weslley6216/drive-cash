class CreateDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :deliveries do |t|
      t.date :date, null: false
      t.decimal :route_value, precision: 10, scale: 2, null: false
      t.decimal :fuel_cost, precision: 10, scale: 2, default: 0
      t.decimal :maintenance_cost, precision: 10, scale: 2, default: 0
      t.decimal :other_costs, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
