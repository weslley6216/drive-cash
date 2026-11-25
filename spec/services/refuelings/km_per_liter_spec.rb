require 'rails_helper'

RSpec.describe Refuelings::KmPerLiter do
  describe '.call' do
    it 'divides the distance between the two odometer readings by the liters of the closing tank' do
      result = described_class.call(from_km: 10_000, to_km: 10_483, liters: BigDecimal('42'))

      expect(result).to eq(BigDecimal('11.5'))
    end

    it 'returns nil when one of the odometer readings is missing' do
      expect(described_class.call(from_km: nil, to_km: 10_483, liters: BigDecimal('42'))).to be_nil
      expect(described_class.call(from_km: 10_000, to_km: nil, liters: BigDecimal('42'))).to be_nil
    end

    it 'returns nil when the odometer did not move forward' do
      expect(described_class.call(from_km: 10_483, to_km: 10_483, liters: BigDecimal('42'))).to be_nil
      expect(described_class.call(from_km: 10_483, to_km: 10_000, liters: BigDecimal('42'))).to be_nil
    end

    it 'returns nil without liters on the closing tank' do
      expect(described_class.call(from_km: 10_000, to_km: 10_483, liters: nil)).to be_nil
      expect(described_class.call(from_km: 10_000, to_km: 10_483, liters: BigDecimal('0'))).to be_nil
    end
  end
end
