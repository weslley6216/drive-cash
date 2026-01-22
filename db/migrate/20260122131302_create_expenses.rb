class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.date :date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :category, null: false
      t.string :vendor
      t.text :description
      t.text :notes
      t.references :trip, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :expenses, :date
    add_index :expenses, :category
  end
end
