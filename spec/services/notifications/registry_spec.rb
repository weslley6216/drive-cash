require 'rails_helper'

RSpec.describe Notifications::Registry do
  it 'lists every generator under the generators namespace' do
    expect(described_class::GENERATORS).to contain_exactly(
      Notifications::Generators::MaintenanceDue,
      Notifications::Generators::GoalReached,
      Notifications::Generators::TankLow,
      Notifications::Generators::WeeklySummary,
      Notifications::Generators::LogReminder
    )
  end

  it 'resolves every registered generator to a presenter of the same kind' do
    kinds = described_class::GENERATORS.map { |generator| generator.name.demodulize.underscore }

    kinds.each do |kind|
      expect { Notifications::Presenters.const_get(kind.camelize) }.not_to raise_error
    end
  end
end
