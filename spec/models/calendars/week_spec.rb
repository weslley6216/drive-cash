require 'rails_helper'

RSpec.describe Calendars::Week do
  describe '.containing' do
    it 'starts the week on the monday of any date' do
      week = described_class.containing(Date.new(2026, 7, 9))

      expect(week.monday).to eq(Date.new(2026, 7, 6))
      expect(week.range).to eq(Date.new(2026, 7, 6)..Date.new(2026, 7, 12))
    end

    it 'treats two dates of the same week as the same week' do
      expect(described_class.containing(Date.new(2026, 7, 6))).to eq(described_class.containing(Date.new(2026, 7, 12)))
    end

    it 'keeps a week across two months from monday to sunday' do
      week = described_class.containing(Date.new(2026, 7, 2))

      expect(week.range).to eq(Date.new(2026, 6, 29)..Date.new(2026, 7, 5))
    end
  end

  describe '.new' do
    it 'normalizes a date given directly to its monday' do
      expect(described_class.new(monday: Date.new(2026, 7, 12)).monday).to eq(Date.new(2026, 7, 6))
    end
  end

  describe '.parse' do
    it 'parses an ISO date into its week' do
      expect(described_class.parse('2026-07-09')).to eq(described_class.containing(Date.new(2026, 7, 6)))
    end

    it 'returns nil for a malformed, blank or missing date' do
      expect(described_class.parse('abc')).to be_nil
      expect(described_class.parse('')).to be_nil
      expect(described_class.parse(nil)).to be_nil
    end

    it 'returns nil for a date longer than the parser accepts' do
      expect(described_class.parse('2' * 200)).to be_nil
    end
  end

  describe 'neighbours' do
    let(:week) { described_class.containing(Date.new(2026, 7, 6)) }

    it 'steps to the previous and the next week' do
      expect(week.previous).to eq(described_class.containing(Date.new(2026, 6, 29)))
      expect(week.next).to eq(described_class.containing(Date.new(2026, 7, 13)))
    end
  end

  describe 'position against today' do
    before { travel_to Time.zone.local(2026, 7, 8, 10, 0) }

    let(:week) { described_class.containing(Date.new(2026, 7, 8)) }

    it 'knows the week of today is current and not future' do
      expect(week).to be_current
      expect(week).not_to be_future
    end

    it 'knows the previous week is neither current nor future' do
      expect(week.previous).not_to be_current
      expect(week.previous).not_to be_future
    end

    it 'knows the next week is future' do
      expect(week.next).to be_future
    end
  end

  describe '#to_param' do
    it 'uses the ISO monday so the week fits in a URL' do
      expect(described_class.containing(Date.new(2026, 7, 9)).to_param).to eq('2026-07-06')
    end
  end
end
