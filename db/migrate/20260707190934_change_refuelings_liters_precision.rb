class ChangeRefuelingsLitersPrecision < ActiveRecord::Migration[8.1]
  def change
    change_column :refuelings, :liters, :decimal, precision: 7, scale: 3
  end
end
