require 'rails_helper'

RSpec.describe Chat::Summaries::Goal do
  describe '#call' do
    it 'builds a goal summary with target, kind and metric' do
      params = { 'kind' => 'monthly', 'target_amount' => 3000.0, 'metric' => 'profit' }

      result = described_class.new(params).call

      expect(result).to include('3.000,00')
      expect(result).to include('lucro')
    end

    it 'uses earnings label when metric is earnings' do
      params = { 'kind' => 'monthly', 'target_amount' => 5000.0, 'metric' => 'earnings' }

      result = described_class.new(params).call

      expect(result).to include('ganhos')
    end
  end
end
