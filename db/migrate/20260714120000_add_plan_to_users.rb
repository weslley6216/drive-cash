class AddPlanToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :plan, :integer, default: 0, null: false
    add_column :users, :plan_billing, :integer
    add_column :users, :plan_since, :datetime
  end
end
