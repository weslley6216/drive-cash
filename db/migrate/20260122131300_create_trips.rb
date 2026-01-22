class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.date :date
      t.text :notes

      t.timestamps
    end
  end
end
