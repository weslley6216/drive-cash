require 'rails_helper'

RSpec.describe Chat::Answers::UnpaidExpenses do
  describe '#call' do
    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'returns no_data when data is empty array' do
      result = described_class.new([]).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats count and total of unpaid expenses' do
      user = create(:user)
      expense1 = create(:expense, user: user, amount: 100.0, paid: false)
      expense2 = create(:expense, user: user, amount: 200.0, paid: false)

      result = described_class.new([expense1, expense2]).call

      expect(result).to include('2')
      expect(result).to include('300,00')
    end
  end
end
