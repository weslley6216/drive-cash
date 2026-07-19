require 'rails_helper'

RSpec.describe Chat::InstallmentInfo do
  describe '#present?' do
    it 'is true when count is at least 2 and the period is valid' do
      info = described_class.new('installments' => 3, 'installments_period' => 'monthly')

      expect(info.present?).to be(true)
    end

    it 'is false below the minimum installment count' do
      info = described_class.new('installments' => Expense::MIN_INSTALLMENTS - 1, 'installments_period' => 'monthly')

      expect(info.present?).to be(false)
    end

    it 'is true at the minimum installment count' do
      info = described_class.new('installments' => Expense::MIN_INSTALLMENTS, 'installments_period' => 'monthly')

      expect(info.present?).to be(true)
    end

    it 'is false when the period is not a known installment period' do
      info = described_class.new('installments' => 3, 'installments_period' => 'fortnightly')

      expect(info.present?).to be(false)
    end

    it 'tolerates blank params' do
      expect(described_class.new(nil).present?).to be(false)
    end
  end

  describe '#count' do
    it 'reads the installments key' do
      expect(described_class.new('installments' => '4').count).to eq(4)
    end

    it 'falls back to the installment_count alias' do
      expect(described_class.new('installment_count' => 5).count).to eq(5)
    end

    it 'returns zero when no value responds to to_i' do
      expect(described_class.new('installments' => []).count).to eq(0)
    end
  end

  describe '#period' do
    it 'reads the installments_period key' do
      expect(described_class.new('installments_period' => 'weekly').period).to eq('weekly')
    end

    it 'falls back to the installment_period alias' do
      expect(described_class.new('installment_period' => 'annual').period).to eq('annual')
    end
  end
end
