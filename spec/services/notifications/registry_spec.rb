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

  it 'derives one kind per generator from its class name' do
    expect(described_class::KINDS).to contain_exactly(
      'maintenance_due', 'goal_reached', 'tank_low', 'weekly_summary', 'log_reminder'
    )
  end

  it 'resolves every registered kind to a presenter of the same name' do
    described_class::KINDS.each do |kind|
      expect { Notifications::Presenters.const_get(kind.camelize, false) }.not_to raise_error
    end
  end
end
