require 'rails_helper'

RSpec.describe Chat::Answers::LastMaintenance do
  describe '#call' do
    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats category and km from maintenance record' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 45_000)

      result = described_class.new(maintenance).call

      expect(result).to include('45000')
    end
  end
end
