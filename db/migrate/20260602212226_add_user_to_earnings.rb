class AddUserToEarnings < ActiveRecord::Migration[8.1]
  def change
    add_reference :earnings, :user, null: true, foreign_key: true
  end
end
