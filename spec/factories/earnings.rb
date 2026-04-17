FactoryBot.define do
  factory :earning do
    date { Date.current }
    amount { 100.00 }
    platform { 'shopee' }
  end
end
