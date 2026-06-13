class AddOdometerUpdatedAtToVehicles < ActiveRecord::Migration[8.1]
  def change
    add_column :vehicles, :odometer_updated_at, :datetime
  end
end
