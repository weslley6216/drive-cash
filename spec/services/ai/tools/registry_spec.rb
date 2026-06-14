require 'rails_helper'

RSpec.describe Ai::Tools::Registry do
  describe '.find' do
    it 'resolves the expense tool wiring' do
      tool = described_class.find('create_expense')

      expect(tool.persister).to eq(Chat::ExpensePersister)
      expect(tool.summary_presenter).to eq(Chat::Summaries::Expense)
      expect(tool.confirm_key).to eq('chat.confirm.success_expense')
      expect(tool.requires_amount).to be(true)
    end

    it 'resolves the earning tool wiring' do
      tool = described_class.find('create_earning')

      expect(tool.persister).to eq(Chat::EarningPersister)
      expect(tool.summary_presenter).to eq(Chat::Summaries::Earning)
      expect(tool.confirm_key).to eq('chat.confirm.success_earning')
    end

    it 'returns nil for an unknown action' do
      expect(described_class.find('unknown_action')).to be_nil
    end
  end

  describe '.declarations' do
    it 'exposes a declaration for every registered tool' do
      names = described_class.declarations.map { |declaration| declaration[:name] }

      expect(names).to contain_exactly('create_earning', 'create_expense')
    end
  end
end
