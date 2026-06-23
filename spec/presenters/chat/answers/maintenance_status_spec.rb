require 'rails_helper'

RSpec.describe Chat::Answers::MaintenanceStatus do
  describe '#call' do
    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'returns all ok when no maintenances are urgent' do
      data = { maintenances: [] }

      result = described_class.new(data).call

      expect(result).to include('em dia')
    end

    it 'lists urgent maintenances' do
      status = double(status_key: 'overdue', maintenance: double(category: 'oil_change'))
      data = { maintenances: [status] }

      result = described_class.new(data).call

      expect(result).to include('overdue')
    end
  end
end
