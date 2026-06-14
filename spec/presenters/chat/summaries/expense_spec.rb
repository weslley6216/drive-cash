require 'rails_helper'

RSpec.describe Chat::Summaries::Expense do
  describe '#call' do
    it 'builds an expense summary with vendor' do
      params = { 'amount' => 45.0, 'category' => 'fuel', 'vendor' => 'Posto Ipiranga', 'date' => '2026-04-23' }

      summary = described_class.new(params).call

      expect(summary).to include('45,00')
      expect(summary).to include('Posto Ipiranga')
      expect(summary).to include('23/04/2026')
    end

    it 'builds an expense summary without vendor' do
      params = { 'amount' => 12.0, 'category' => 'meals', 'date' => '2026-04-24' }

      summary = described_class.new(params).call

      expect(summary).to include('12,00')
      expect(summary).to include('24/04/2026')
    end

    it 'includes installment info when the params describe a valid plan' do
      params = {
        'amount' => 300.0,
        'category' => 'maintenance',
        'vendor' => 'Oficina',
        'date' => '2026-04-24',
        'installments' => 3,
        'installments_period' => 'monthly'
      }

      summary = described_class.new(params).call

      expect(summary).to include('3x')
      expect(summary).to include('mensal')
    end

    it 'falls back to a capitalized category when the key is unknown' do
      params = { 'amount' => 10, 'category' => 'subscription', 'date' => '2026-04-24' }

      summary = described_class.new(params).call

      expect(summary).to include('Subscription')
    end
  end
end
