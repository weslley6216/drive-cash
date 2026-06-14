require 'rails_helper'

RSpec.describe Chat::Summaries::Earning do
  describe '#call' do
    it 'builds an earning summary with amount, platform and date' do
      params = { 'amount' => 150.5, 'platform' => 'uber', 'date' => '2026-04-23' }

      summary = described_class.new(params).call

      expect(summary).to include('150,50')
      expect(summary).to match(/uber/i)
      expect(summary).to include('23/04/2026')
    end

    it 'formats amounts >= 1000 with thousands separator' do
      params = { 'amount' => 1234.5, 'platform' => 'uber', 'date' => '2026-04-23' }

      summary = described_class.new(params).call

      expect(summary).to include('1.234,50')
    end

    it 'falls back to a capitalized platform when the key is unknown' do
      params = { 'amount' => 10, 'platform' => 'indrive', 'date' => '2026-04-23' }

      summary = described_class.new(params).call

      expect(summary).to include('Indrive')
    end

    it 'returns the raw date string when the date is invalid' do
      params = { 'amount' => 10, 'platform' => 'uber', 'date' => 'invalid-date' }

      summary = described_class.new(params).call

      expect(summary).to include('invalid-date')
    end
  end
end
