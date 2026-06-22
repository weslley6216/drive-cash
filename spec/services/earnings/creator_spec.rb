require 'rails_helper'

RSpec.describe Earnings::Creator do
  let(:user) { create(:user) }

  describe '.call' do
    let(:valid_params) do
      { date: '2026-05-22', amount: '245.00', platform: 'uber', notes: 'test', trips_count: 7 }
    end

    it 'creates an earning owned by the user' do
      result = described_class.call(valid_params, user: user)

      expect(result.success?).to be(true)
      expect(result.earning.user).to eq(user)
      expect(result.earning.platform).to eq('uber')
    end

    it 'returns failure with errors when earning is invalid' do
      result = described_class.call({ amount: '0', platform: 'uber', date: '2026-05-22' }, user: user)

      expect(result.success?).to be(false)
      expect(result.earning.errors).to be_present
    end

    it 'ignores user_id forged inside the attributes payload' do
      other = create(:user)

      result = described_class.call(valid_params.merge(user_id: other.id), user: user)

      expect(result.earning.user).to eq(user)
    end
  end
end
