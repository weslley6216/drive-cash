FactoryBot.define do
  factory :expense do
    association :trip
    date { Date.current }
    amount { 50.00 }
    category { 'fuel' }
  end
end
