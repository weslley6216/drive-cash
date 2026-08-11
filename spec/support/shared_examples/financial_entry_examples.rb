RSpec.shared_examples 'a financial entry scope' do |factory|
  it '.for_year returns entries with date inside the given year' do
    entry_dec_2024 = create(factory, date: Date.new(2024, 12, 31))
    entry_jan_2025 = create(factory, date: Date.new(2025, 1, 1))
    entry_dec_2025 = create(factory, date: Date.new(2025, 12, 31))

    result = described_class.for_year(2025)

    expect(result).to include(entry_jan_2025, entry_dec_2025)
    expect(result).not_to include(entry_dec_2024)
  end

  it '.for_year returns all when year is blank' do
    entry_jan_2025 = create(factory, date: Date.new(2025, 1, 1))

    expect(described_class.for_year(nil)).to include(entry_jan_2025)
    expect(described_class.for_year('')).to include(entry_jan_2025)
  end

  it '.for_month returns entries matching the month' do
    entry_jan_2025 = create(factory, date: Date.new(2025, 1, 1))
    entry_dec_2025 = create(factory, date: Date.new(2025, 12, 31))

    result = described_class.for_month(1)

    expect(result).to include(entry_jan_2025)
    expect(result).not_to include(entry_dec_2025)
  end

  it '.in_period filters by year only when month is nil' do
    entry_jan_2025 = create(factory, date: Date.new(2025, 1, 1))
    entry_dec_2025 = create(factory, date: Date.new(2025, 12, 31))
    entry_dec_2024 = create(factory, date: Date.new(2024, 12, 31))

    result = described_class.in_period(2025)

    expect(result).to include(entry_jan_2025, entry_dec_2025)
    expect(result).not_to include(entry_dec_2024)
  end

  it '.in_period filters by year and month when month is given' do
    entry_jan_2025 = create(factory, date: Date.new(2025, 1, 1))
    entry_dec_2025 = create(factory, date: Date.new(2025, 12, 31))

    result = described_class.in_period(2025, 1)

    expect(result).to include(entry_jan_2025)
    expect(result).not_to include(entry_dec_2025)
  end
end
