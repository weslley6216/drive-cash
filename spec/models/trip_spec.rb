require 'rails_helper'

RSpec.describe Trip, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:earnings).dependent(:destroy) }
    it { is_expected.to have_many(:expenses).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    
    it 'validates numericality of route_value' do
      trip = build(:trip, route_value: -10)

      expect(trip).not_to be_valid
      expect(trip.errors[:route_value]).to include("deve ser maior ou igual a 0")
    end
  end

  describe '#save_data_structure' do
    context 'when creating a trip with valid attributes' do
      let(:trip) { create(:trip, route_value: 150.00, fuel_cost: 50.00, platform: 'uber') }

      it 'creates the trip record' do
        expect(trip).to be_persisted
      end

      it 'automatically creates an associated earning' do
        expect(trip.earnings.count).to eq(1)
        expect(trip.earnings.first.amount).to eq(150.00)
        expect(trip.earnings.first.platform).to eq('uber')
      end

      it 'automatically creates associated expenses' do
        expect(trip.expenses.count).to eq(1)
        expect(trip.expenses.first.category).to eq('fuel')
        expect(trip.expenses.first.amount).to eq(50.00)
      end
    end

    context 'when values are zero' do
      let(:trip) { create(:trip, route_value: 0.0, fuel_cost: 0.0) }

      it 'does not create earning records' do
        expect(trip.earnings.count).to eq(0)
      end

      it 'does not create expense records' do
        expect(trip.expenses.count).to eq(0)
      end
    end
  end
end
