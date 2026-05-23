require 'rails_helper'

RSpec.describe Dashboard::CategoryBreakdownService do
  describe '#call' do
    it 'groups expenses by category and returns top 4 by amount' do
      create(:expense, date: Date.new(2025, 6, 1),  amount: 300, category: 'fuel',        paid: true)
      create(:expense, date: Date.new(2025, 6, 5),  amount: 200, category: 'maintenance', paid: true)
      create(:expense, date: Date.new(2025, 6, 10), amount: 100, category: 'meals',       paid: true)
      create(:expense, date: Date.new(2025, 6, 15), amount:  80, category: 'phone',       paid: true)
      create(:expense, date: Date.new(2025, 6, 20), amount:  10, category: 'parking',     paid: true)

      result = described_class.new(year: 2025, month: 6).call

      expect(result.size).to eq(4)
      expect(result.map { |r| r[:id] }).to eq(%w[fuel maintenance meals phone])
    end

    it 'computes percent of total per category' do
      create(:expense, date: Date.new(2025, 6, 1), amount: 300, category: 'fuel',  paid: true)
      create(:expense, date: Date.new(2025, 6, 2), amount: 100, category: 'meals', paid: true)

      result = described_class.new(year: 2025, month: 6).call

      expect(result.find { |r| r[:id] == 'fuel'  }[:percent]).to eq(75.0)
      expect(result.find { |r| r[:id] == 'meals' }[:percent]).to eq(25.0)
    end

    it 'translates the category label' do
      create(:expense, date: Date.new(2025, 6, 1), amount: 100, category: 'fuel', paid: true)

      row = described_class.new(year: 2025, month: 6).call.first

      expect(row[:label]).to eq(I18n.t('activerecord.attributes.expense.categories.fuel'))
    end

    it 'returns the META color and icon for the category' do
      create(:expense, date: Date.new(2025, 6, 1), amount: 100, category: 'fuel', paid: true)

      row = described_class.new(year: 2025, month: 6).call.first

      expect(row[:color]).to eq('#dc2626')
      expect(row[:icon]).to eq(PhlexIcons::Lucide::Fuel)
    end

    it 'falls back to slate color and Package icon for categories without META' do
      create(:expense, date: Date.new(2025, 6, 1), amount: 100, category: 'other', paid: true)

      row = described_class.new(year: 2025, month: 6).call.first

      expect(row[:color]).to eq('#94a3b8')
      expect(row[:icon]).to eq(PhlexIcons::Lucide::Package)
    end

    it 'ignores unpaid expenses' do
      create(:expense, date: Date.new(2025, 6, 1), amount: 100, category: 'fuel', paid: true)
      create(:expense, date: Date.new(2025, 6, 1), amount: 999, category: 'fuel', paid: false)

      row = described_class.new(year: 2025, month: 6).call.first

      expect(row[:amount].to_f).to eq(100.0)
    end

    it 'returns empty array when there are no expenses' do
      result = described_class.new(year: 2025, month: 6).call

      expect(result).to eq([])
    end

    it 'covers the whole year when month is nil' do
      create(:expense, date: Date.new(2025, 1, 1),  amount: 100, category: 'fuel', paid: true)
      create(:expense, date: Date.new(2025, 12, 1), amount: 200, category: 'fuel', paid: true)

      result = described_class.new(year: 2025).call

      expect(result.first[:amount].to_f).to eq(300.0)
    end

    it 'respects custom limit' do
      %w[fuel maintenance meals phone parking].each_with_index do |cat, i|
        create(:expense, date: Date.new(2025, 6, i + 1), amount: 100 - i, category: cat, paid: true)
      end

      result = described_class.new(year: 2025, month: 6, limit: 2).call

      expect(result.size).to eq(2)
    end
  end
end
