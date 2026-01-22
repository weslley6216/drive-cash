FactoryBot.define do
  factory :earning do
    association :trip
    date { Date.current }
    amount { 100.00 }
    platform { 'shopee' }
  end
end
