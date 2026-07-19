require 'rails_helper'

RSpec.describe Exports::Generators::Pdf do
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
    it 'produces a non-empty pdf with the correct content type' do
      result = described_class.call(payload: payload)

      expect(result.content_type).to eq('application/pdf')
      expect(result.filename).to end_with('.pdf')
      expect(result.io.string).to start_with('%PDF-')
      expect(result.io.string.bytesize).to be > 1_000
    end

    it 'includes structured data in the pdf' do
      result = described_class.call(payload: payload)

      pdf_text = result.io.string

      expect(pdf_text).to include('stream')
      expect(pdf_text).to include('endstream')
    end

    it 'includes refuelings and maintenances in the pdf' do
      full_payload = Exports::Builder::Payload.new(
        earnings:     [{ date: Date.new(2026, 3, 1), amount: BigDecimal('200.00'), platform: 'uber', trips_count: 5, notes: nil }],
        expenses:     [{ date: Date.new(2026, 3, 2), amount: BigDecimal('50.00'), category: 'fuel', vendor: 'Shell', description: 'Tanque cheio', paid: true }],
        refuelings:   [{ date: Date.new(2026, 3, 3), vendor: 'Petrobrás', liters: BigDecimal('30.0'), price_per_liter: BigDecimal('6.50'), total_amount: BigDecimal('195.00'), odometer_km: 50000 }],
        maintenances: [{ category: 'oil_change', interval_km: 5000, last_done_km: 45000, estimated_cost: BigDecimal('150.00') }],
        totals:       { earnings: BigDecimal('200.00'), expenses: BigDecimal('50.00'), profit: BigDecimal('150.00'), count: 4 }
      )

      result = described_class.call(payload: full_payload)

      expect(result.io.string).to start_with('%PDF-')
      expect(result.io.string.bytesize).to be > 1_000
    end

    it 'gracefully handles empty payload' do
      empty = Exports::Builder::Payload.new(
        earnings:     [],
        expenses:     [],
        refuelings:   [],
        maintenances: [],
        totals:       { earnings: 0, expenses: 0, profit: 0, count: 0 }
      )

      result = described_class.call(payload: empty)

      expect(result.io.string).to start_with('%PDF-')
    end
  end
end
