FactoryBot.define do
  factory :goal do
    user
    kind { 'monthly' }
    target_amount { 7000.00 }
    period_start { Date.current.beginning_of_month }
    period_end { Date.current.end_of_month }
    metric { 'profit' }
  end
end
