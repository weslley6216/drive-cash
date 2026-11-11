FactoryBot.define do
  factory :maintenance do
    vehicle
    category { 'oil_change' }
    last_done_km { 45_000 }
    interval_km { 5_000 }
    estimated_cost { 280.00 }
  end
end
