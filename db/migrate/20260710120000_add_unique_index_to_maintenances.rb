class AddUniqueIndexToMaintenances < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL)
      DELETE FROM maintenances
      WHERE id NOT IN (
        SELECT MAX(id) FROM maintenances GROUP BY vehicle_id, category
      )
    SQL

    add_index :maintenances, [:vehicle_id, :category], unique: true
  end

  def down
    remove_index :maintenances, column: [:vehicle_id, :category]
  end
end
