require 'rails_helper'

RSpec.describe Exports::Generators::Csv do
  let(:payload) do
    Exports::Builder::Payload.new(
      earnings:     [{ date: Date.new(2026, 3, 1), amount: BigDecimal('200.00'), platform: 'uber', trips_count: 5, notes: nil }],
      expenses:     [{ date: Date.new(2026, 3, 2), amount: BigDecimal('50.00'), category: 'fuel', vendor: 'Shell', description: 'Tanque cheio', paid: true }],
      refuelings:   [],
      maintenances: [],
      totals:       { earnings: BigDecimal('200.00'), expenses: BigDecimal('50.00'), profit: BigDecimal('150.00'), count: 2 }
    )
  end

  describe '.call' do
    it 'returns a file struct with csv content type' do
      result = described_class.call(payload: payload)

      expect(result.content_type).to eq('text/csv')
      expect(result.filename).to end_with('.csv')
    end

    it 'includes a section header for each non-empty section' do
      result = described_class.call(payload: payload)
      body = result.io.string

      expect(body).to include('# Receitas')
      expect(body).to include('# Despesas')
    end

    it 'lists each row with values' do
      result = described_class.call(payload: payload)
      body = result.io.string

      expect(body).to include('2026-03-01')
      expect(body).to include('200.00')
      expect(body).to include('Shell')
    end

    it 'translates enum keys to localized labels' do
      result = described_class.call(payload: payload)
      body = result.io.string

      expect(body).to include('Uber')
      expect(body).to include('Combustível')
    end

    it 'omits sections that are empty' do
      result = described_class.call(payload: payload)
      body = result.io.string

      expect(body).not_to include('# Abastecimentos')
      expect(body).not_to include('# Manutenções')
    end

    it 'neutralizes formula injection in string cells' do
      malicious_payload = Exports::Builder::Payload.new(
        earnings:     [],
        expenses:     [{ date: Date.new(2026, 3, 2), amount: BigDecimal('50.00'), category: 'fuel', vendor: '=SUM(A1:A10)', description: '+cmd', paid: true }],
        refuelings:   [],
        maintenances: [],
        totals:       { earnings: BigDecimal('0'), expenses: BigDecimal('50.00'), profit: BigDecimal('-50.00'), count: 1 }
      )

      result = described_class.call(payload: malicious_payload)
      body = result.io.string

      expect(body).to include("'=SUM(A1:A10)")
      expect(body).to include("'+cmd")
    end
  end
end
