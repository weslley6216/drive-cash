require 'rails_helper'

RSpec.describe Dashboard::PercentChange do
  describe '.between' do
    it 'returns the rounded percent change between two values' do
      expect(described_class.between(150, 100)).to eq(50.0)
    end

    it 'returns a negative value when current is smaller' do
      expect(described_class.between(80, 100)).to eq(-20.0)
    end

    it 'rounds to one decimal place' do
      expect(described_class.between(123.456, 100)).to eq(23.5)
    end

    it 'uses the absolute value of previous as divisor' do
      expect(described_class.between(50, -100)).to eq(150.0)
    end

    it 'returns nil when previous is zero' do
      expect(described_class.between(100, 0)).to be_nil
    end

    it 'returns nil when previous is exactly zero as float' do
      expect(described_class.between(100, 0.0)).to be_nil
    end

    it 'coerces non-numeric values via to_f' do
      expect(described_class.between('150', '100')).to eq(50.0)
    end
  end
end
