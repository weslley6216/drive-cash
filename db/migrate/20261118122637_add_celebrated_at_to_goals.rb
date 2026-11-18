class AddCelebratedAtToGoals < ActiveRecord::Migration[8.1]
  def change
    add_column :goals, :celebrated_at, :datetime
  end
end
