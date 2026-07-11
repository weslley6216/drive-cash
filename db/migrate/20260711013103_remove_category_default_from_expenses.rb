class RemoveCategoryDefaultFromExpenses < ActiveRecord::Migration[8.1]
  def change
    change_column_default :expenses, :category, from: 10, to: nil
  end
end
