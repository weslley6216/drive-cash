require 'rails_helper'

RSpec.describe Chat::Answers::HistorySearch do
  describe '#call' do
    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'returns history_empty when no results' do
      data = { term: 'Shell', earnings: [], expenses: [] }

      result = described_class.new(data).call

      expect(result).to eq(I18n.t('chat.answer.history_empty', term: 'Shell'))
    end

    it 'returns history_found with total count' do
      user = create(:user)
      earning = create(:earning, user: user)
      expense = create(:expense, user: user)
      data = { term: 'uber', earnings: [earning], expenses: [expense] }

      result = described_class.new(data).call

      expect(result).to eq(I18n.t('chat.answer.history_found', count: 2, term: 'uber'))
    end
  end
end
