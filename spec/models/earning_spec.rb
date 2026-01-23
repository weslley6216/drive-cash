require 'rails_helper'

RSpec.describe Earning, type: :model do
  describe 'validations' do
    subject { build(:earning) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:trip) }
  end

  describe 'enums' do
    it { should define_enum_for(:platform).with_values(
      amazon: 0,
      ifood: 1,
      mercado_livre: 2,
      nine_nine: 3,
      rappi: 4,
      shopee: 5,
      uber: 6,
      other: 7
    ).with_prefix.backed_by_column_of_type(:integer) }
  end

  describe 'scopes' do
    let(:earning_2024) { create(:earning, date: '2024-05-10') }
    let(:earning_2025) { create(:earning, date: '2025-05-10') }
    let(:earning_jan) { create(:earning, date: '2025-01-10') }

    it '.for_year returns earnings matching the year' do
      expect(described_class.for_year(2025)).to include(earning_2025, earning_jan)
      expect(described_class.for_year(2025)).not_to include(earning_2024)
    end

    it '.for_month returns earnings matching the month' do
      expect(described_class.for_month(5)).to include(earning_2024, earning_2025)
      expect(described_class.for_month(5)).not_to include(earning_jan)
    end
  end

  describe '.total_by_platform' do
    before do
      create(:earning, platform: :shopee, amount: 100)
      create(:earning, platform: :shopee, amount: 50)
      create(:earning, platform: :mercado_livre, amount: 200)
    end

    it 'groups and sums amounts returning platform names as strings' do
      result = described_class.total_by_platform

      expect(result['shopee']).to eq(150.0)
      expect(result['mercado_livre']).to eq(200.0)
    end
  end
end
