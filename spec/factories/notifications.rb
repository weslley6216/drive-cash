FactoryBot.define do
  factory :notification do
    user
    kind { 'log_reminder' }
    data { { 'date' => Date.current.to_s } }
  end
end
