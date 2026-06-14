require 'rails_helper'

RSpec.describe Dashboard::Insights::Presenters do
  describe '.present' do
    it 'renders category_spike monthly description with current and previous month names' do
      raw = {
        type:     'category_spike',
        severity: 'warning',
        payload:  {
          mode:           :monthly,
          category:       'Combustível',
          pct:            120.0,
          amount:         220.0,
          previous_year:  2025,
          month:          6,
          previous_month: 5
        }
      }

      result = described_class.present(raw)

      expect(result[:type]).to eq('category_spike')
      expect(result[:severity]).to eq('warning')
      expect(result[:title]).to include('Combustível')
      expect(result[:title]).to include('120')
      expect(result[:description]).to include('220,00')
      expect(result[:description]).to include('junho')
      expect(result[:description]).to include('maio')
    end

    it 'renders category_spike annual description without month name' do
      raw = {
        type:     'category_spike',
        severity: 'warning',
        payload:  {
          mode:          :annual,
          category:      'Combustível',
          pct:           30.0,
          amount:        220.0,
          previous_year: 2024,
          month:         nil
        }
      }

      result = described_class.present(raw)

      expect(result[:description]).to include('2024')
      expect(result[:description]).not_to include('mês')
    end

    it 'renders best_day with formatted amount in the title and localized date in description' do
      date = Date.new(2025, 6, 10)
      raw  = { type: 'best_day', severity: 'info', payload: { date: date, amount: 500.0 } }

      result = described_class.present(raw)

      expect(result[:title]).to include('500,00')
      expect(result[:description]).to include(I18n.l(date, format: :default))
    end

    it 'renders worst_platform with per-trip amount formatted' do
      raw = { type: 'worst_platform', severity: 'info', payload: { platform: 'Shopee', per_trip: 25.0 } }

      result = described_class.present(raw)

      expect(result[:title]).to include('Shopee')
      expect(result[:description]).to include('25,00')
    end

    it 'renders margin_drop with raw pp and current_margin values' do
      raw = { type: 'margin_drop', severity: 'critical', payload: { pp: 80.0, current_margin: 10.0 } }

      result = described_class.present(raw)

      expect(result[:title]).to include('80')
      expect(result[:description]).to include('10')
    end
  end

  describe 'producer/presenter coverage' do
    it 'defines a presenter for every insight rule emitted by InsightsService' do
      Dashboard::InsightsService::INSIGHT_RULES.each do |rule|
        expect(described_class.const_defined?(rule.name.demodulize)).to be(true)
      end
    end
  end
end
