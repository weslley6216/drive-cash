FactoryBot.define do
  factory :trip do
    date { Date.current }
    route_value { 0.00 }
    fuel_cost { 0.00 }
    maintenance_cost { 0.00 }
    other_costs { 0.00 }
    platform { 'shopee' }

    trait :with_values do
      route_value { 200.00 }
      fuel_cost { 50.00 }
    end
  end
end
