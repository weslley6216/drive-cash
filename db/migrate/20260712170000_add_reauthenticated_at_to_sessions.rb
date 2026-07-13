class AddReauthenticatedAtToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :reauthenticated_at, :datetime
  end
end
