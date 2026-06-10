FactoryBot.define do
  factory :maintenance do
    vehicle
    sequence(:name) { |offset| "Manutenção #{offset}" }
    category { 'oil_change' }
    due_at_km { 49_000 }
    due_at_date { Date.current + 18.days }
    estimated_cost { 180.00 }
    completed { false }
  end
end
