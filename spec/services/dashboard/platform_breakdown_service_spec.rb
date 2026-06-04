require 'rails_helper'

RSpec.describe Dashboard::PlatformBreakdownService do
  let(:user) { create(:user) }

  describe '#call' do
    it 'groups earnings by platform and returns top 5 by amount' do
      create(:earning, user: user, date: Date.new(2025, 6, 1),  amount: 800, platform: 'uber')
      create(:earning, user: user, date: Date.new(2025, 6, 2),  amount: 500, platform: 'ifood')
      create(:earning, user: user, date: Date.new(2025, 6, 3),  amount: 300, platform: 'rappi')
      create(:earning, user: user, date: Date.new(2025, 6, 4),  amount: 200, platform: 'shopee')
      create(:earning, user: user, date: Date.new(2025, 6, 5),  amount: 100, platform: 'amazon')
      create(:earning, user: user, date: Date.new(2025, 6, 6),  amount:  50, platform: 'nine_nine')

      result = described_class.new(year: 2025, month: 6, user: user).call

      expect(result.size).to eq(5)
      expect(result.map { |row| row[:id] }).to eq(%w[uber ifood rappi shopee amazon])
    end

    it 'computes percent of total per platform' do
      create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 750, platform: 'uber')
      create(:earning, user: user, date: Date.new(2025, 6, 2), amount: 250, platform: 'ifood')

      result = described_class.new(year: 2025, month: 6, user: user).call

      expect(result.find { |row| row[:id] == 'uber'  }[:percent]).to eq(75.0)
      expect(result.find { |row| row[:id] == 'ifood' }[:percent]).to eq(25.0)
    end

    it 'translates the platform label' do
      create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 100, platform: 'uber')

      row = described_class.new(year: 2025, month: 6, user: user).call.first

      expect(row[:label]).to eq(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'returns the META color for the platform' do
      create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 100, platform: 'uber')

      row = described_class.new(year: 2025, month: 6, user: user).call.first

      expect(row[:color]).to eq('#000000')
    end

    it 'falls back to slate color for platforms without META mapping' do
      create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 100, platform: 'other')

      row = described_class.new(year: 2025, month: 6, user: user).call.first

      expect(row[:color]).to eq('#94a3b8')
    end

    it 'returns empty array when there are no earnings' do
      result = described_class.new(year: 2025, month: 6, user: user).call

      expect(result).to eq([])
    end

    it 'covers the whole year when month is nil' do
      create(:earning, user: user, date: Date.new(2025, 1, 1),  amount: 100, platform: 'uber')
      create(:earning, user: user, date: Date.new(2025, 12, 1), amount: 200, platform: 'uber')

      result = described_class.new(year: 2025, user: user).call

      expect(result.first[:amount].to_f).to eq(300.0)
    end

    it 'respects custom limit' do
      %w[uber ifood rappi shopee amazon nine_nine].each_with_index do |platform, offset|
        create(:earning, user: user, date: Date.new(2025, 6, offset + 1), amount: 100 - offset, platform: platform)
      end

      result = described_class.new(year: 2025, month: 6, limit: 3, user: user).call

      expect(result.size).to eq(3)
    end
  end
end
