require 'rails_helper'

RSpec.describe Vehicles::TankBalanceService do
  def fuel_expense(user, amount, date)
    create(:expense, user: user, category: 'fuel', amount: amount, date: date)
  end

  it 'computes balance as refuelings minus standalone fuel expenses' do
    user = create(:user)
    vehicle = create(:vehicle, user: user)
    create(:refueling, vehicle: vehicle, total_amount: 260, full_tank: true, date: Date.new(2026, 6, 7))
    3.times { |offset| fuel_expense(user, 45, Date.new(2026, 6, 8 + offset)) }

    result = described_class.new(user: user).call

    expect(result[:balance]).to eq(125)
    expect(result[:full]).to eq(260)
    expect(result[:status_key]).to eq(:ok)
  end

  it 'excludes fuel expenses that produced a refueling from the debit' do
    user = create(:user)
    vehicle = create(:vehicle, user: user)
    fill_expense = fuel_expense(user, 260, Date.new(2026, 6, 7))
    create(:refueling, vehicle: vehicle, expense: fill_expense, total_amount: 260, full_tank: true, date: Date.new(2026, 6, 7))

    result = described_class.new(user: user).call

    expect(result[:balance]).to eq(260)
  end

  it 'reports negative when consumption exceeds credits' do
    user = create(:user)
    vehicle = create(:vehicle, user: user)
    create(:refueling, vehicle: vehicle, total_amount: 260, full_tank: true, date: Date.new(2026, 6, 7))
    fuel_expense(user, 300, Date.new(2026, 6, 9))

    result = described_class.new(user: user).call

    expect(result[:balance]).to eq(-40)
    expect(result[:status_key]).to eq(:negative)
  end

  it 'orders moves by date desc mixing credits and debits' do
    user = create(:user)
    vehicle = create(:vehicle, user: user)
    create(:refueling, vehicle: vehicle, total_amount: 260, full_tank: true, date: Date.new(2026, 6, 7))
    fuel_expense(user, 45, Date.new(2026, 6, 10))

    moves = described_class.new(user: user).call[:moves]

    expect(moves.first[:kind]).to eq(:debit)
    expect(moves.first[:amount]).to eq(-45)
    expect(moves.last[:kind]).to eq(:credit)
  end

  it 'accumulates credits minus debits since anchor' do
    user = create(:user)
    vehicle = create(:vehicle, user: user)
    create(:refueling, vehicle: vehicle, total_amount: 260, full_tank: true, date: Date.new(2025, 12, 19))
    create(:refueling, vehicle: vehicle, total_amount: 260, full_tank: true, date: Date.new(2026, 1, 5))
    fuel_expense(user, 45, Date.new(2025, 12, 20))
    fuel_expense(user, 45, Date.new(2026, 1, 4))

    result = described_class.new(user: user).call

    expect(result[:balance]).to eq(430)
  end

  it 'ignores fuel expenses before the anchor date' do
    user = create(:user)
    vehicle = create(:vehicle, user: user)
    create(:refueling, vehicle: vehicle, total_amount: 260, full_tank: true, date: Date.new(2025, 12, 19))
    fuel_expense(user, 1000, Date.new(2024, 6, 1))
    fuel_expense(user, 500, Date.new(2025, 12, 18))
    fuel_expense(user, 45, Date.new(2025, 12, 20))

    result = described_class.new(user: user).call

    expect(result[:balance]).to eq(215)
  end

  it 'returns empty payload without a vehicle' do
    user = create(:user)

    result = described_class.new(user: user).call

    expect(result[:balance]).to eq(0)
    expect(result[:moves]).to eq([])
  end

  it 'returns EMPTY when vehicle has no refuelings' do
    user = create(:user)
    create(:vehicle, user: user)

    result = described_class.new(user: user).call

    expect(result).to eq(described_class::EMPTY)
  end
end
