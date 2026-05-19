class AddTripsCountToEarnings < ActiveRecord::Migration[8.1]
  def change
    add_column :earnings, :trips_count, :integer, default: 1, null: false
  end
end
