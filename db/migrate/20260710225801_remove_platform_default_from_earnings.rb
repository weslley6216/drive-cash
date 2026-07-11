class RemovePlatformDefaultFromEarnings < ActiveRecord::Migration[8.1]
  def change
    change_column_default :earnings, :platform, from: 7, to: nil
  end
end
