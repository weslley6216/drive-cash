class RequireUserOnExpensesAndEarnings < ActiveRecord::Migration[8.1]
  def up
    change_column_null :expenses, :user_id, false
    change_column_null :earnings, :user_id, false
  end

  def down
    change_column_null :expenses, :user_id, true
    change_column_null :earnings, :user_id, true
  end
end
