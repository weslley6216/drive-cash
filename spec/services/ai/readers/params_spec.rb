require 'rails_helper'

RSpec.describe Ai::Readers::Params do
  describe '#safe_year' do
    it 'returns current year for nil input' do
      obj = Class.new { include Ai::Readers::Params }.new

      expect(obj.safe_year(nil)).to eq(Date.current.year)
    end

    it 'passes through a valid year unchanged' do
      obj = Class.new { include Ai::Readers::Params }.new

      expect(obj.safe_year(2024)).to eq(2024)
    end

    it 'clamps a future year to current year + 1' do
      obj = Class.new { include Ai::Readers::Params }.new

      expect(obj.safe_year(9999)).to eq(Date.current.year + 1)
    end

    it 'clamps a year before 2000 to 2000' do
      obj = Class.new { include Ai::Readers::Params }.new

      expect(obj.safe_year(1999)).to eq(2000)
    end
  end

  describe '#safe_month' do
    it 'returns nil for nil input' do
      obj = Class.new { include Ai::Readers::Params }.new

      expect(obj.safe_month(nil)).to be_nil
    end

    it 'passes through a valid month unchanged' do
      obj = Class.new { include Ai::Readers::Params }.new

      expect(obj.safe_month(6)).to eq(6)
    end

    it 'clamps a month above 12 to 12' do
      obj = Class.new { include Ai::Readers::Params }.new

      expect(obj.safe_month(15)).to eq(12)
    end

    it 'clamps a month below 1 to 1' do
      obj = Class.new { include Ai::Readers::Params }.new

      expect(obj.safe_month(0)).to eq(1)
    end
  end
end
