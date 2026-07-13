FactoryBot.define do
  factory :user do
    sequence(:name) { |offset| "Motorista #{offset}" }
    sequence(:email_address) { |offset| "driver#{offset}@gmail.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    phone { '(11) 98765-4321' }
  end
end
