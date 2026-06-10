FactoryBot.define do
  factory :vehicle do
    user
    brand { 'Honda' }
    vehicle_model { 'Civic' }
    year { 2018 }
    license_plate { 'ABC-1D23' }
    odometer_km { 48_230 }
  end
end
