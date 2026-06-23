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

      expect(names).to include('create_earning', 'create_expense')
    end
  end

  describe 'query tool wiring' do
    it 'every query tool has kind :query, reader and answer_presenter' do
      query_tools = described_class.all.select(&:query?)

      query_tools.each do |tool|
        expect(tool.kind).to eq(:query), "#{tool.name} missing kind"
        expect(tool.reader).not_to be_nil, "#{tool.name} missing reader"
        expect(tool.answer_presenter).not_to be_nil, "#{tool.name} missing answer_presenter"
      end
    end

    it 'existing create tools keep kind :create and have no reader' do
      %w[create_earning create_expense].each do |name|
        tool = described_class.find(name)

        expect(tool.kind).to eq(:create)
        expect(tool.reader).to be_nil
      end
    end
  end
end
