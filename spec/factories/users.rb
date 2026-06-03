FactoryBot.define do
  factory :user do
    sequence(:name) { |offset| "Motorista #{offset}" }
    sequence(:email_address) { |offset| "driver#{offset}@drivecash.test" }
    password              { 'password123' }
    password_confirmation { 'password123' }
  end
end
