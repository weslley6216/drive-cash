require 'rails_helper'

RSpec.describe Exports::Generators::Json do
  let(:payload) do
    Exports::Builder::Payload.new(
      earnings:     [{ date: Date.new(2026, 3, 1), amount: BigDecimal('200.00'), platform: 'uber', trips_count: 5, notes: nil }],
      expenses:     [],
      refuelings:   [],
      maintenances: [],
      totals:       { earnings: BigDecimal('200.00'), expenses: BigDecimal('0'), profit: BigDecimal('200.00'), count: 1 }
    )
  end

  describe '.call' do
    it 'returns a json file struct' do
      result = described_class.call(payload: payload)

      expect(result.content_type).to eq('application/json')
      expect(result.filename).to end_with('.json')
    end

    it 'serializes all sections and totals' do
      result = described_class.call(payload: payload)
      parsed = JSON.parse(result.io.string)

      expect(parsed.keys).to match_array(%w[earnings expenses refuelings maintenances totals])
      expect(parsed['earnings'].first['platform']).to eq('uber')
      expect(parsed['totals']['profit']).to eq('200.0')
    end
  end
end
