module Notifications
  module Registry
    GENERATORS = [
      Generators::MaintenanceDue,
      Generators::GoalReached,
      Generators::TankLow,
      Generators::WeeklySummary,
      Generators::LogReminder
    ].freeze
  end
end
