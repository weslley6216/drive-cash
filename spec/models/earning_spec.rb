require 'rails_helper'

RSpec.describe Earning, type: :model do
  describe 'validations' do
    subject { build(:earning) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:amount) }

    it 'rejects amount equal to zero' do
      earning = build(:earning, amount: 0)

      earning.valid?

      expect(earning.errors[:amount]).to be_present
    end

    it 'produces only one error when amount is blank' do
      earning = build(:earning, amount: nil)

      earning.valid?

      expect(earning.errors[:amount].size).to eq(1)
    end
  end

  describe 'enums' do
    it {
      should define_enum_for(:platform).with_values(
        amazon: 0,
        ifood: 1,
        mercado_livre: 2,
        nine_nine: 3,
        rappi: 4,
        shopee: 5,
        uber: 6,
        other: 7
      ).with_prefix.backed_by_column_of_type(:integer)
    }
  end

  describe 'scopes' do
    let(:earning_dec_2024) { create(:earning, date: Date.new(2024, 12, 31)) }
    let(:earning_jan_2025) { create(:earning, date: Date.new(2025, 1, 1)) }
    let(:earning_dec_2025) { create(:earning, date: Date.new(2025, 12, 31)) }

    it '.for_year returns earnings with date inside the given year' do
      expect(described_class.for_year(2025)).to include(earning_jan_2025, earning_dec_2025)
      expect(described_class.for_year(2025)).not_to include(earning_dec_2024)
    end

    it '.for_year returns all when year is blank' do
      earning_jan_2025

      expect(described_class.for_year(nil)).to include(earning_jan_2025)
      expect(described_class.for_year('')).to include(earning_jan_2025)
    end

    it '.for_month returns earnings matching the month' do
      earning_jan_2025
      earning_dec_2025

      expect(described_class.for_month(1)).to include(earning_jan_2025)
      expect(described_class.for_month(1)).not_to include(earning_dec_2025)
    end
  end

  describe 'trips_count' do
    it 'defaults to 1' do
      earning = build(:earning)

      expect(earning.trips_count).to eq(1)
    end

    it 'is invalid when less than 1' do
      earning = build(:earning, trips_count: 0)

      expect(earning).not_to be_valid
    end
  end

  describe 'sanitize_amount' do
    it 'converts comma-separated value to float' do
      earning = build(:earning, amount: '45,90')

      earning.valid?

      expect(earning.amount).to eq(45.90)
    end
  end

  describe 'user association' do
    it 'is invalid without a user' do
      earning = build(:earning, user: nil)

      earning.valid?

      expect(earning.errors[:user]).to be_present
    end

    it 'can be associated with a user' do
      user = create(:user)
      earning = create(:earning, user: user)

      expect(earning.user).to eq(user)
    end
  end
end
