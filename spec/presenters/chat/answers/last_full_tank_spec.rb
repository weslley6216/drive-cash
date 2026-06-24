require 'rails_helper'

RSpec.describe Chat::Answers::LastFullTank do
  describe '#call' do
    it 'returns no_full_tank when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_full_tank'))
    end

    it 'formats date and vendor from refueling record' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      refueling = create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 10), vendor: 'Ipiranga')

      result = described_class.new(refueling).call

      expect(result).to include('Ipiranga')
      expect(result).to include('10 de junho')
    end

    it 'shows ? when vendor is blank' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      refueling = create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 10), vendor: nil)

      result = described_class.new(refueling).call

      expect(result).to include('?')
    end
  end
end
