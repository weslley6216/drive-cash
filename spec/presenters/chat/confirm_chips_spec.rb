require 'rails_helper'

RSpec.describe Chat::ConfirmChips do
  describe '.for' do
    it 'returns dashboard and earnings chips for create_earning' do
      chips = described_class.for('create_earning')

      expect(chips.map(&:label)).to eq(%w[chat.confirm.btn_dashboard chat.confirm.btn_earnings])
      expect(chips.map(&:route)).to eq(%i[root_path dashboard_earnings_detail_path])
    end

    it 'returns expenses and home chips for create_expense' do
      chips = described_class.for('create_expense')

      expect(chips.map(&:label)).to eq(%w[chat.confirm.btn_expenses chat.confirm.btn_home])
      expect(chips.map(&:route)).to eq(%i[dashboard_expenses_detail_path root_path])
    end

    it 'falls back to a single home chip for an unknown action' do
      chips = described_class.for('unknown_action')

      expect(chips.map(&:label)).to eq(['chat.confirm.btn_home'])
      expect(chips.map(&:route)).to eq([:root_path])
    end
  end
end
