class MakeRefuelingImportedFieldsOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :refuelings, :liters, true
    change_column_null :refuelings, :odometer_km, true
  end
end
