FactoryBot.define do
  factory :refueling do
    vehicle
    expense { nil }
    date { Date.current }
    vendor { 'Posto Orense' }
    liters { 32.50 }
    total_amount { 180.50 }
    odometer_km { 48_230 }
    full_tank { true }
  end
end
