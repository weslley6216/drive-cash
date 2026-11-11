class AddDismissedAtToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :dismissed_at, :datetime
  end
end
