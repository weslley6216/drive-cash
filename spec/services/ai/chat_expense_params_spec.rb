require 'rails_helper'

RSpec.describe Ai::ChatExpenseParams do
  let(:base) do
    {
      'date'        => '2026-01-10',
      'amount'      => '90.00',
      'category'    => 'maintenance',
      'vendor'      => 'Pneus',
      'description' => 'Pneus'
    }
  end

  describe '#attributes' do
    it 'keeps only the expense attribute keys from a hash' do
      params = described_class.new(base.merge('installments' => 3, 'installments_period' => 'monthly'))

      expect(params.attributes.keys).to match_array(%w[date amount category vendor description])
    end

    it 'discards a forged user_id from a hash payload' do
      params = described_class.new(base.merge('user_id' => 99))

      expect(params.attributes).not_to have_key('user_id')
    end

    it 'permits and stringifies ActionController::Parameters, dropping unknown keys' do
      raw = ActionController::Parameters.new(base.merge('malicious' => 'x'))

      params = described_class.new(raw)

      expect(params.attributes).to include('category' => 'maintenance')
      expect(params.attributes).not_to have_key('malicious')
    end

    it 'treats blank input as empty attributes' do
      expect(described_class.new(nil).attributes).to eq({})
    end
  end

  describe '#installments' do
    it 'returns zero when absent' do
      expect(described_class.new(base).installments).to eq(0)
    end

    it 'coerces the raw value to an integer' do
      expect(described_class.new(base.merge('installments' => '3')).installments).to eq(3)
    end
  end

  describe '#period' do
    it 'returns an empty string when absent' do
      expect(described_class.new(base).period).to eq('')
    end

    it 'returns the period string when present' do
      expect(described_class.new(base.merge('installments_period' => 'weekly')).period).to eq('weekly')
    end
  end
end
