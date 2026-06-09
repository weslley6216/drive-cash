class AddCompositeDateIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :earnings, [:user_id, :date]
    add_index :expenses, [:user_id, :date, :paid]

    remove_index :expenses, :paid, if_exists: true
    remove_index :earnings, :date, if_exists: true
    remove_index :expenses, :date, if_exists: true
  end
end
