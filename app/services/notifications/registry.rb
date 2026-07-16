module Notifications
  module Registry
    GENERATORS = [
      Generators::MaintenanceDue,
      Generators::GoalReached,
      Generators::TankLow,
      Generators::WeeklySummary,
      Generators::LogReminder
    ].freeze

    KINDS = GENERATORS.map { |generator| generator.name.demodulize.underscore }.freeze
  end
end
