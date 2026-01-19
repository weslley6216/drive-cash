puts "🌱 Clearing database..."
Delivery.destroy_all

puts "📦 Creating deliveries for 2024..."

deliveries_data = [
  # JUNE 2024
  { date: "2024-06-01", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 21.98 },
  { date: "2024-06-08", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-09", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-10", route_value: 240, fuel_cost: 40, maintenance_cost: 600, other_costs: 0 },
  { date: "2024-06-11", route_value: 0, fuel_cost: 0, maintenance_cost: 700, other_costs: 0 },
  { date: "2024-06-12", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-13", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-15", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-16", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-19", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-20", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-21", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-22", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-24", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-25", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-28", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-06-29", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },

  # JULY 2024
  { date: "2024-07-02", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-03", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-04", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-05", route_value: 240, fuel_cost: 40, maintenance_cost: 0, other_costs: 30 },
  { date: "2024-07-06", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 2 },
  { date: "2024-07-08", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-09", route_value: 270, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-10", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-12", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-14", route_value: 270, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-15", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-16", route_value: 240, fuel_cost: 30, maintenance_cost: 850, other_costs: 0 },
  { date: "2024-07-17", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-18", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-20", route_value: 480, fuel_cost: 60, maintenance_cost: 0, other_costs: 2 },
  { date: "2024-07-21", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-22", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-23", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-24", route_value: 0, fuel_cost: 0, maintenance_cost: 120, other_costs: 0 },
  { date: "2024-07-25", route_value: 480, fuel_cost: 60, maintenance_cost: 0, other_costs: 2 },
  { date: "2024-07-26", route_value: 240, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-27", route_value: 480, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-29", route_value: 480, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-07-31", route_value: 0, fuel_cost: 0, maintenance_cost: 400, other_costs: 0 },

  # AUGUST 2024
  { date: "2024-08-01", route_value: 0, fuel_cost: 0, maintenance_cost: 0, other_costs: 22.86 },
  { date: "2024-08-03", route_value: 480, fuel_cost: 80, maintenance_cost: 0, other_costs: 30 },
  { date: "2024-08-10", route_value: 0, fuel_cost: 0, maintenance_cost: 0, other_costs: 178.73 },
  { date: "2024-08-14", route_value: 264, fuel_cost: 40, maintenance_cost: 70, other_costs: 110 },
  { date: "2024-08-15", route_value: 244, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-16", route_value: 0, fuel_cost: 0, maintenance_cost: 900, other_costs: 0 },
  { date: "2024-08-17", route_value: 244, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-19", route_value: 217, fuel_cost: 25, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-21", route_value: 264, fuel_cost: 25, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-22", route_value: 264, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-23", route_value: 217, fuel_cost: 40, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-24", route_value: 498, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-26", route_value: 217, fuel_cost: 25, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-27", route_value: 217, fuel_cost: 25, maintenance_cost: 80, other_costs: 0 },
  { date: "2024-08-28", route_value: 478, fuel_cost: 80, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-29", route_value: 214, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-30", route_value: 478, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-08-31", route_value: 508, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },

  # SEPTEMBER 2024
  { date: "2024-09-01", route_value: 0, fuel_cost: 0, maintenance_cost: 0, other_costs: 27.86 },
  { date: "2024-09-03", route_value: 214, fuel_cost: 25, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-04", route_value: 214, fuel_cost: 25, maintenance_cost: 0, other_costs: 30 },
  { date: "2024-09-05", route_value: 214, fuel_cost: 25, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-06", route_value: 214, fuel_cost: 25, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-09", route_value: 264, fuel_cost: 25, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-10", route_value: 214, fuel_cost: 25, maintenance_cost: 0, other_costs: 173.78 },
  { date: "2024-09-11", route_value: 227, fuel_cost: 32, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-12", route_value: 478, fuel_cost: 64, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-13", route_value: 214, fuel_cost: 32, maintenance_cost: 0, other_costs: 12 },
  { date: "2024-09-14", route_value: 511, fuel_cost: 64, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-15", route_value: 264, fuel_cost: 32, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-16", route_value: 267, fuel_cost: 32, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-17", route_value: 478, fuel_cost: 64, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-18", route_value: 267, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-20", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 500 },
  { date: "2024-09-21", route_value: 297, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-22", route_value: 264, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-23", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-24", route_value: 217, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-25", route_value: 217, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-26", route_value: 217, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-27", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-28", route_value: 508, fuel_cost: 70, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-09-29", route_value: 267, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },

  # OCTOBER 2024
  { date: "2024-10-01", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 27.86 },
  { date: "2024-10-02", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 30 },
  { date: "2024-10-03", route_value: 478, fuel_cost: 70, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-04", route_value: 267, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-05", route_value: 514, fuel_cost: 70, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-07", route_value: 217, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-09", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-10", route_value: 267, fuel_cost: 35, maintenance_cost: 0, other_costs: 173.78 },
  { date: "2024-10-11", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 49.98 },
  { date: "2024-10-12", route_value: 561, fuel_cost: 70, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-13", route_value: 267, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-14", route_value: 478, fuel_cost: 70, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-15", route_value: 217, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-16", route_value: 267, fuel_cost: 35, maintenance_cost: 40, other_costs: 0 },
  { date: "2024-10-17", route_value: 224, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-18", route_value: 217, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-19", route_value: 247, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-21", route_value: 481, fuel_cost: 70, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-25", route_value: 0, fuel_cost: 0, maintenance_cost: 2418, other_costs: 0 },
  { date: "2024-10-26", route_value: 294, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-27", route_value: 264, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-28", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-29", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-30", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-10-31", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },

  # NOVEMBER 2024
  { date: "2024-11-01", route_value: 214, fuel_cost: 30, maintenance_cost: 0, other_costs: 27.86 },
  { date: "2024-11-04", route_value: 259, fuel_cost: 30, maintenance_cost: 0, other_costs: 223.78 },
  { date: "2024-11-05", route_value: 262, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-06", route_value: 214, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-07", route_value: 217, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-09", route_value: 339, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-10", route_value: 267, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-11", route_value: 481, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-12", route_value: 262, fuel_cost: 30, maintenance_cost: 40, other_costs: 0 },
  { date: "2024-11-13", route_value: 312, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-14", route_value: 292, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-15", route_value: 282.10, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-16", route_value: 826.10, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-18", route_value: 267, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-19", route_value: 262, fuel_cost: 30, maintenance_cost: 0, other_costs: 40 },
  { date: "2024-11-20", route_value: 618, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-21", route_value: 264, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-22", route_value: 214, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-23", route_value: 734, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-25", route_value: 214, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-26", route_value: 214, fuel_cost: 30, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-27", route_value: 214, fuel_cost: 30, maintenance_cost: 0, other_costs: 5.10 },
  { date: "2024-11-28", route_value: 225.40, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-11-29", route_value: 227.20, fuel_cost: 60, maintenance_cost: 0, other_costs: 0 },

  # DECEMBER 2024
  { date: "2024-12-01", route_value: 0, fuel_cost: 0, maintenance_cost: 0, other_costs: 27.86 },
  { date: "2024-12-02", route_value: 217, fuel_cost: 35, maintenance_cost: 0, other_costs: 203.78 },
  { date: "2024-12-03", route_value: 484, fuel_cost: 70, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-12-04", route_value: 217, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-12-05", route_value: 214, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-12-06", route_value: 264, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-12-07", route_value: 294, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-12-08", route_value: 354, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-12-09", route_value: 264, fuel_cost: 35, maintenance_cost: 0, other_costs: 0 },
  { date: "2024-12-11", route_value: 0, fuel_cost: 0, maintenance_cost: 0, other_costs: 250 },
  { date: "2024-12-31", route_value: 0, fuel_cost: 0, maintenance_cost: 1923, other_costs: 0 }
]

deliveries_data.each do |data|
  Delivery.create!(data)
end

puts "✅ #{Delivery.count} deliveries created successfully!"

# Statistics
total_earnings = Delivery.sum(:route_value)
total_expenses = Delivery.sum("fuel_cost + maintenance_cost + other_costs")
total_profit = total_earnings - total_expenses

puts "\n📊 Statistics:"
puts "Total Earnings: R$ #{total_earnings.to_f.round(2)}"
puts "Total Expenses: R$ #{total_expenses.to_f.round(2)}"
puts "Total Profit: R$ #{total_profit.to_f.round(2)}"
