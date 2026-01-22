# spec/models/earning_spec.rb
require 'rails_helper'

RSpec.describe Earning, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to define_enum_for(:platform).with_values(
      shopee: 'shopee',
      ifood: 'ifood',
      uber: 'uber',
      nine_nine: '99',
      other: 'other'
    ).with_prefix.backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:earning_2024) { create(:earning, date: '2024-05-10') }
    let!(:earning_2025) { create(:earning, date: '2025-05-10') }
    let!(:earning_jan) { create(:earning, date: '2025-01-10') }

    it '.for_year returns earnings matching the year' do
      expect(described_class.for_year(2025)).to include(earning_2025, earning_jan)
      expect(described_class.for_year(2025)).not_to include(earning_2024)
    end

    it '.for_month returns earnings matching the month' do
      expect(described_class.for_month(5)).to include(earning_2024, earning_2025)
      expect(described_class.for_month(5)).not_to include(earning_jan)
    end
  end
end
