require 'rails_helper'

RSpec.describe Chat::Summaries::Maintenance do
  describe '#call' do
    it 'builds a maintenance summary with the localized category' do
      params = { 'category' => 'oil_change', 'done_km' => 50_000 }

      result = described_class.new(params).call

      expect(result).to include(I18n.t('vehicle.maintenances.catalog.oil_change'))
      expect(result).to include('50000')
    end

    it 'omits km part when done_km is absent' do
      params = { 'category' => 'oil_change' }

      result = described_class.new(params).call

      expect(result).not_to include(' aos ')
    end
  end
end
