FactoryBot.define do
  factory :earning do
    user
    date { Date.current }
    amount { 100.00 }
    platform { 'shopee' }
    trips_count { 1 }
  end
end
