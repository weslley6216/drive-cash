FactoryBot.define do
  factory :expense do
    user
    date { Date.current }
    amount { 50.00 }
    category { 'fuel' }
    paid { true }
  end
end
