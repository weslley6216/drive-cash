require 'rails_helper'

RSpec.describe Ai::SummaryBuilder do
  describe '.build' do
    it 'builds an earning summary correctly' do
      params = { 'amount' => 150.5, 'platform' => 'uber', 'date' => '2026-04-23' }
      summary = described_class.build('create_earning', params)

      expect(summary).to include('150,50')
      expect(summary).to match(/uber/i)
      expect(summary).to include('23/04/2026')
    end

    it 'builds an expense summary with vendor correctly' do
      params = { 'amount' => 45.0, 'category' => 'fuel', 'vendor' => 'Posto Ipiranga', 'date' => '2026-04-23' }
      summary = described_class.build('create_expense', params)

      expect(summary).to include('45,00')
      expect(summary).to include('Posto Ipiranga')
      expect(summary).to include('23/04/2026')
    end

    it 'builds an expense summary without vendor correctly' do
      params = { 'amount' => 12.0, 'category' => 'meals', 'date' => '2026-04-24' }
      summary = described_class.build('create_expense', params)

      expect(summary).to include('12,00')
      expect(summary).to include('24/04/2026')
    end

    it 'includes installment info in the expense summary when valid' do
      params = {
        'amount' => 300.0,
        'category' => 'maintenance',
        'vendor' => 'Oficina',
        'date' => '2026-04-24',
        'installments' => 3,
        'installments_period' => 'monthly'
      }
      summary = described_class.build('create_expense', params)

      expect(summary).to include('3x')
      expect(summary).to include('mensal')
    end

    it 'formats amounts >= 1000 with thousands separator' do
      params = { 'amount' => 1234.5, 'platform' => 'uber', 'date' => '2026-04-23' }
      summary = described_class.build('create_earning', params)

      expect(summary).to include('1.234,50')
    end

    it 'returns the fallback message for an unknown action' do
      summary = described_class.build('unknown_action', {})
      expect(summary).to eq(I18n.t('chat.message.fallback'))
    end

    it 'handles invalid dates gracefully returning the raw string' do
      params = { 'amount' => 10, 'platform' => 'uber', 'date' => 'invalid-date' }
      summary = described_class.build('create_earning', params)

      expect(summary).to include('invalid-date')
    end
  end
end
