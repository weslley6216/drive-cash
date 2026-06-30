FactoryBot.define do
  factory :export do
    user
    period_kind { 'year' }
    period_start { Date.new(2026, 1, 1) }
    period_end { Date.new(2026, 12, 31) }
    format { 'pdf' }
    status { 'pending' }
    includes { { 'earnings' => true, 'expenses' => true, 'refuelings' => true, 'maintenances' => false } }
  end
end
