class RedesignMaintenancesForKm < ActiveRecord::Migration[8.1]
  def change
    add_column :maintenances, :last_done_km, :integer
    add_column :maintenances, :interval_km, :integer
    remove_index :maintenances, column: %i[vehicle_id completed], if_exists: true
    remove_column :maintenances, :due_at_km, :integer
    remove_column :maintenances, :due_at_date, :date
    remove_column :maintenances, :completed, :boolean, default: false, null: false
    remove_column :maintenances, :name, :string, null: false
  end
end
