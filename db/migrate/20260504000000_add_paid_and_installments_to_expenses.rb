class AddPaidAndInstallmentsToExpenses < ActiveRecord::Migration[8.1]
  def change
    change_table :expenses, bulk: true do |t|
      t.boolean :paid, null: false, default: true
      t.uuid :installment_series_id
      t.integer :installment_number
      t.integer :installment_count
    end

    add_index :expenses, :installment_series_id
    add_index :expenses, :paid
  end
end
