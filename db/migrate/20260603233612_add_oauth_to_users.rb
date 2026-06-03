class AddOauthToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid,      :string
    add_index  :users, %i[provider uid], unique: true
  end
end
