require 'rails_helper'

RSpec.describe Dashboard::Insights::Presenter do
  describe '#call' do
    it 'renders category_spike monthly description with month name and previous year' do
      raw = {
        type: 'category_spike',
        severity: 'warning',
        payload: {
          mode: :monthly,
          category: 'Combustível',
          pct: 120.0,
          amount: 220.0,
          previous_year: 2024,
          month: 6
        }
      }

      result = described_class.new(raw).call

      expect(result[:type]).to eq('category_spike')
      expect(result[:severity]).to eq('warning')
      expect(result[:title]).to include('Combustível')
      expect(result[:title]).to include('120')
      expect(result[:description]).to include('220,00')
      expect(result[:description]).to include('junho')
      expect(result[:description]).to include('2024')
    end

    it 'renders category_spike annual description without month name' do
      raw = {
        type: 'category_spike',
        severity: 'warning',
        payload: {
          mode: :annual,
          category: 'Combustível',
          pct: 30.0,
          amount: 220.0,
          previous_year: 2024,
          month: nil
        }
      }

      result = described_class.new(raw).call

      expect(result[:description]).to include('2024')
      expect(result[:description]).not_to include('mês')
    end

    it 'renders best_day with formatted amount in the title and localized date in description' do
      date = Date.new(2025, 6, 10)
      raw  = { type: 'best_day', severity: 'info', payload: { date: date, amount: 500.0 } }

      result = described_class.new(raw).call

      expect(result[:title]).to include('500,00')
      expect(result[:description]).to include(I18n.l(date, format: :default))
    end

    it 'renders worst_platform with per-trip amount formatted' do
      raw = { type: 'worst_platform', severity: 'info', payload: { platform: 'Shopee', per_trip: 25.0 } }

      result = described_class.new(raw).call

      expect(result[:title]).to include('Shopee')
      expect(result[:description]).to include('25,00')
    end

    it 'renders margin_drop with raw pp and current_margin values' do
      raw = { type: 'margin_drop', severity: 'critical', payload: { pp: 80.0, current_margin: 10.0 } }

      result = described_class.new(raw).call

      expect(result[:title]).to include('80')
      expect(result[:description]).to include('10')
    end
  end
end
