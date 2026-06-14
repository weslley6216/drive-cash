require 'rails_helper'

RSpec.describe History::EntryRows do
  describe '.for' do
    it 'resolves an earning to its entry-row presenter' do
      earning = build(:earning)

      expect(described_class.for(earning)).to be_a(History::EntryRows::Earning)
    end

    it 'resolves an expense to its entry-row presenter' do
      expense = build(:expense)

      expect(described_class.for(expense)).to be_a(History::EntryRows::Expense)
    end
  end
end
