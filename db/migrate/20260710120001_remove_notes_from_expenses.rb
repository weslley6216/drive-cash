class RemoveNotesFromExpenses < ActiveRecord::Migration[8.1]
  def change
    remove_column :expenses, :notes, :text
  end
end
