class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.decimal :target_amount, precision: 10, scale: 2, null: false
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.string :metric, default: 'profit', null: false

      t.timestamps
    end

    add_index :goals, [:user_id, :kind, :period_start], unique: true
  end
end
