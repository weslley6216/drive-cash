FactoryBot.define do
  factory :delivery do
    date { Date.current }
    route_value { 250.00 }
    fuel_cost { 60.00 }
    maintenance_cost { 20.00 }
    other_costs { 10.00 }
  end
end
