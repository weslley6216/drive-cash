class CreateExports < ActiveRecord::Migration[8.1]
  def change
    create_table :exports do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :period_kind, null: false, default: 0
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.integer :format, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.jsonb :includes, null: false, default: { earnings: true, expenses: true, refuelings: true, maintenances: false }
      t.timestamps
    end

    add_index :exports, %i[user_id created_at]
  end
end
