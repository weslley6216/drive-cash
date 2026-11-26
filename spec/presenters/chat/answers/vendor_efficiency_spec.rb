require 'rails_helper'

RSpec.describe Chat::Answers::VendorEfficiency do
  describe '#call' do
    it 'returns vendor_efficiency_no_data when nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.vendor_efficiency_no_data'))
    end

    it 'returns the winner and the runner-up as a card payload' do
      data = Refuelings::VendorEfficiency::Comparison.new(
        winner: 'Posto Orense', winner_kml: 11.5, runner_up: 'Geladão', runner_up_kml: 11.0, savings: 28
      )

      result = described_class.new(data).call

      expect(result.to_h).to eq(winner: 'Posto Orense', winner_kml: 11.5, runner_up: 'Geladão', runner_up_kml: 11.0, savings: 28)
    end

    it 'keeps the sentence when there is no runner-up to compare' do
      data = Refuelings::VendorEfficiency::Comparison.new(
        winner: 'Shell', winner_kml: 12.456, runner_up: nil, runner_up_kml: nil, savings: 0
      )

      result = described_class.new(data).call

      expect(result).to include('Shell').and include('12.46').and include("R$\u00A00,00")
    end
  end
end
