class ConvertEnumsToIntegersAndAddIndexes < ActiveRecord::Migration[7.1]
  def up
    add_column :expenses, :category_new, :integer, default: 10
    
    expense_mapping = {
      'car_wash' => 0, 'documentation' => 1, 'fine' => 2, 'fuel' => 3,
      'insurance' => 4, 'maintenance' => 5, 'meals' => 6, 'parking' => 7,
      'phone' => 8, 'toll' => 9, 'other' => 10
    }

    expense_mapping.each do |old_val, new_val|
      execute "UPDATE expenses SET category_new = #{new_val} WHERE category = '#{old_val}'"
    end

    remove_column :expenses, :category
    rename_column :expenses, :category_new, :category
    change_column_null :expenses, :category, false

    add_column :earnings, :platform_new, :integer, default: 7
    
    platform_mapping = {
      '99' => 0, 'amazon' => 1, 'ifood' => 2, 'mercado_livre' => 3,
      'rappi' => 4, 'shopee' => 5, 'uber' => 6, 'other' => 7
    }

    platform_mapping.each do |old_val, new_val|
      execute "UPDATE earnings SET platform_new = #{new_val} WHERE platform = '#{old_val}'"
    end

    remove_column :earnings, :platform
    rename_column :earnings, :platform_new, :platform
    change_column_null :earnings, :platform, false

    add_index :expenses, :category
    add_index :expenses, [:date, :category]
    add_index :earnings, :platform
    add_index :earnings, [:date, :platform]
  end

  def down
    add_column :expenses, :category_string, :string
    {
      0 => 'car_wash', 1 => 'documentation', 2 => 'fine', 3 => 'fuel',
      4 => 'insurance', 5 => 'maintenance', 6 => 'meals', 7 => 'parking',
      8 => 'phone', 9 => 'toll', 10 => 'other'
    }.each do |int_val, str_val|
      execute "UPDATE expenses SET category_string = '#{str_val}' WHERE category = #{int_val}"
    end
    remove_column :expenses, :category
    rename_column :expenses, :category_string, :category

    add_column :earnings, :platform_string, :string
    {
      0 => '99', 1 => 'amazon', 2 => 'ifood', 3 => 'mercado_livre',
      4 => 'rappi', 5 => 'shopee', 6 => 'uber', 7 => 'other'
    }.each do |int_val, str_val|
      execute "UPDATE earnings SET platform_string = '#{str_val}' WHERE platform = #{int_val}"
    end
    remove_column :earnings, :platform
    rename_column :earnings, :platform_string, :platform
  end
end
