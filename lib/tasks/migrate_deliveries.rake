# lib/tasks/migrate_deliveries.rake
namespace :data do
  desc "Migra dados de Delivery para Earnings e Expenses"
  task migrate_to_new_structure: :environment do
    puts "Migrando #{Delivery.count} deliveries..."
    
    Delivery.find_each do |delivery|
      # Cria earning
      Earning.create!(
        date: delivery.date,
        amount: delivery.route_value,
        platform: 'shopee', # ou extrair de algum lugar
        notes: "Migrado de delivery ##{delivery.id}"
      )
      
      # Cria expenses se houver
      if delivery.fuel_cost >= 0
        Expense.create!(
          date: delivery.date,
          amount: delivery.fuel_cost,
          category: :fuel,
          notes: "Migrado de delivery ##{delivery.id}"
        )
      end
      
      if delivery.maintenance_cost >= 0
        Expense.create!(
          date: delivery.date,
          amount: delivery.maintenance_cost,
          category: :maintenance,
          notes: "Migrado de delivery ##{delivery.id}"
        )
      end
      
      if delivery.other_costs >= 0
        Expense.create!(
          date: delivery.date,
          amount: delivery.other_costs,
          category: :other,
          notes: "Migrado de delivery ##{delivery.id}"
        )
      end
      
      print "."
    end
    
    puts "\n✅ Migração concluída!"
    puts "Earnings: #{Earning.count}"
    puts "Expenses: #{Expense.count}"
  end
  
  desc "Limpa dados migrados (rollback)"
  task rollback_migration: :environment do
    puts "Limpando dados migrados..."
    Earning.destroy_all
    Expense.destroy_all
    puts "✅ Rollback concluído!"
  end
end
