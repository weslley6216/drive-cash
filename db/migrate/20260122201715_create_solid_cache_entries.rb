class CreateSolidCacheEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_cache_entries, if_not_exists: true do |t|
      t.binary   :key,        null: false,   limit: 1024, index: { unique: true, length: 1024 }
      t.binary   :value,      null: false,   limit: 536870912
      t.datetime :created_at, null: false,   index: true
      t.integer  :key_hash,   null: false,   limit: 8,    index: { unique: true }
      t.integer  :byte_size,  null: false,   limit: 4
    end
  end
end
