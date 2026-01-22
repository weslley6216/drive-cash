class CreateEarnings < ActiveRecord::Migration[8.0]
  def change
    create_table :earnings do |t|
      t.date :date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :platform
      t.text :notes
      t.references :trip, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :earnings, :date
    add_index :earnings, :platform
  end
end