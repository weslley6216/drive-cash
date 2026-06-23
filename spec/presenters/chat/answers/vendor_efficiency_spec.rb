require 'rails_helper'

RSpec.describe Chat::Answers::VendorEfficiency do
  describe '#call' do
    it 'returns vendor_efficiency_no_data when nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.vendor_efficiency_no_data'))
    end

    it 'formats vendor, kml and savings' do
      data = double(winner: 'Shell', winner_kml: 12.456, savings: 80.0)

      result = described_class.new(data).call

      expect(result).to include('Shell').and include('12.46').and include('80,00')
    end
  end
end
