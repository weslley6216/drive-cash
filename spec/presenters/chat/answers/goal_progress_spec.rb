require 'rails_helper'

RSpec.describe Chat::Answers::GoalProgress do
  describe '#call' do
    it 'returns no_goal when data is empty' do
      result = described_class.new({}).call

      expect(result).to eq(I18n.t('chat.answer.no_goal'))
    end

    it 'returns on_track message when monthly goal is on track' do
      data = {
        monthly: { current: 1500.0, target: 2000.0, on_track: true, remaining_per_day: 50.0 }
      }

      result = described_class.new(data).call

      expect(result).to include('50,00')
      expect(result).to include('500,00')
    end

    it 'returns off_track message when goal is behind' do
      data = {
        monthly: { current: 500.0, target: 3000.0, on_track: false, remaining_per_day: 125.0 }
      }

      result = described_class.new(data).call

      expect(result).to include('125,00')
    end

    it 'prefers monthly over annual and weekly' do
      data = {
        monthly: { current: 1000.0, target: 2000.0, on_track: true, remaining_per_day: 33.0 },
        annual:  { current: 10_000.0, target: 36_000.0, on_track: false, remaining_per_day: 100.0 }
      }

      result = described_class.new(data).call

      expect(result).to include('33,00')
    end

    it 'falls back to annual when monthly is absent' do
      data = {
        annual: { current: 5000.0, target: 36_000.0, on_track: false, remaining_per_day: 85.0 }
      }

      result = described_class.new(data).call

      expect(result).to include('85,00')
    end
  end
end
