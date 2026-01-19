puts "🌱 Clearing 2026 records..."
Delivery.where('EXTRACT(YEAR FROM date) = ?', 2026).destroy_all

puts "📦 Creating deliveries for 2026..."

deliveries_data = [
  # JANEIRO 2026
  { date: "2026-01-02", route_value: 260, fuel_cost: 45, maintenance_cost: 0, other_costs: 165.16 },
  { date: "2026-01-03", route_value: 335, fuel_cost: 45, maintenance_cost: 0, other_costs: 0 },
  { date: "2026-01-04", route_value: 475, fuel_cost: 45, maintenance_cost: 0, other_costs: 0 },
  { date: "2026-01-05", route_value: 260, fuel_cost: 45, maintenance_cost: 0, other_costs: 0 },
  { date: "2026-01-07", route_value: 245, fuel_cost: 45, maintenance_cost: 0, other_costs: 32.45 },
  { date: "2026-01-08", route_value: 287.3, fuel_cost: 45, maintenance_cost: 0, other_costs: 0 },
  { date: "2026-01-10", route_value: 314.5, fuel_cost: 45, maintenance_cost: 0, other_costs: 0 },
  { date: "2026-01-12", route_value: 245, fuel_cost: 45, maintenance_cost: 0, other_costs: 803.81 },
  { date: "2026-01-13", route_value: 245, fuel_cost: 45, maintenance_cost: 0, other_costs: 35 },
  { date: "2026-01-14", route_value: 245, fuel_cost: 45, maintenance_cost: 0, other_costs: 35 },
  { date: "2026-01-17", route_value: 589.1, fuel_cost: 90, maintenance_cost: 0, other_costs: 70 }
]

deliveries_data.each do |data|
  Delivery.create!(data)
end

puts "✅ #{Delivery.where('EXTRACT(YEAR FROM date) = ?', 2026).count} deliveries created for 2026!"

# Overall Statistics (Since 2026 is usually the last one to run)
total_earnings = Delivery.sum(:route_value)
total_expenses = Delivery.sum("fuel_cost + maintenance_cost + other_costs")
total_profit = total_earnings - total_expenses

puts "\n📊 Total Statistics (All Years):"
puts "Total Earnings: R$ #{total_earnings.to_f.round(2)}"
puts "Total Expenses: R$ #{total_expenses.to_f.round(2)}"
puts "Total Profit: R$ #{total_profit.to_f.round(2)}"
