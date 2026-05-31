require 'rails_helper'

RSpec.describe History::FeedService do
  describe '#call' do
    context 'with no records in the period' do
      it 'returns empty groups and zeroed summary' do
        result = described_class.new(year: 2020).call

        expect(result[:groups]).to eq([])
        expect(result[:summary]).to eq(
          earnings: 0,
          expenses: 0,
          net: 0
        )
      end
    end
  end
end
