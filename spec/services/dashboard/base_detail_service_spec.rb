require 'rails_helper'

RSpec.describe Dashboard::BaseDetailService do
  describe '#call' do
    let(:jan_earning) { create(:earning, date: Date.new(2025, 1, 10), amount: 100) }
    let(:feb_earning) { create(:earning, date: Date.new(2025, 2, 15), amount: 200) }

    before { jan_earning; feb_earning }

    let(:service_class) do
      Class.new(described_class) do
        private

        def base_scope
          Earning
        end

        def empty_scope
          Earning.none
        end

        def list_key
          :items
        end

        def by_month_key
          :items_by_month
        end
      end
    end

    it 'returns monthly detail when month is present' do
      result = service_class.new(year: 2025, month: 1).call

      expect(result[:annual]).to eq(false)
      expect(result[:items].to_a).to eq([jan_earning])
      expect(result[:items_by_month]).to be_nil
      expect(result[:total]).to eq(100.0)
    end

    it 'returns annual detail when month is blank' do
      result = service_class.new(year: 2025, month: nil).call

      expect(result[:annual]).to eq(true)
      expect(result[:items]).to eq(Earning.none)
      expect(result[:items_by_month].size).to eq(2)
      expect(result[:items_by_month].map { |row| row[:month] }).to eq([1, 2])
      expect(result[:items_by_month].map { |row| row[:month_name] }).to include('janeiro', 'fevereiro')
      expect(result[:total]).to eq(300.0)
    end
  end

  describe 'abstract methods' do
    subject(:service) { described_class.new(year: 2025, month: nil) }

    it 'raises NotImplementedError for base_scope' do
      expect { service.send(:base_scope) }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for empty_scope' do
      expect { service.send(:empty_scope) }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for list_key' do
      expect { service.send(:list_key) }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for by_month_key' do
      expect { service.send(:by_month_key) }.to raise_error(NotImplementedError)
    end
  end
end
