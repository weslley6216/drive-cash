class DropTripsAndRemoveTripId < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :earnings, :trips
    remove_foreign_key :expenses, :trips

    remove_index :earnings, :trip_id
    remove_index :expenses, :trip_id

    remove_column :earnings, :trip_id
    remove_column :expenses, :trip_id

    drop_table :trips
  end

  def down
    create_table :trips do |t|
      t.date :date
      t.text :notes
      t.timestamps
    end

    add_column :earnings, :trip_id, :bigint, null: false, default: 0
    add_column :expenses, :trip_id, :bigint, null: false, default: 0

    add_index :earnings, :trip_id
    add_index :expenses, :trip_id

    add_foreign_key :earnings, :trips
    add_foreign_key :expenses, :trips
  end
end
