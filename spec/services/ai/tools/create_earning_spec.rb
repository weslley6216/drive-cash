require 'rails_helper'

RSpec.describe Ai::Tools::CreateEarning do
  describe '.declaration' do
    it 'requires amount, date and platform' do
      required = described_class.declaration[:parameters][:required]

      expect(required).to match_array(%w[amount date platform])
    end
  end
end
