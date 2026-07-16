FactoryBot.define do
  factory :user do
    sequence(:name) { |offset| "Motorista #{offset}" }
    sequence(:email_address) { |offset| "driver#{offset}@gmail.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    phone { '(11) 98765-4321' }

    trait :pro do
      plan { :pro }
      plan_billing { :yearly }
      plan_since { Time.zone.local(2026, 3, 3) }
    end
  end
end
