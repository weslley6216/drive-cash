module Notifications
  module Registry
    GENERATORS = [
      Generators::MaintenanceDue,
      Generators::TankLow,
      Generators::GoalReached,
      Generators::WeeklySummary,
      Generators::LogReminder
    ].freeze

    def self.kind_for(generator) = generator.name.demodulize.underscore

    KINDS = GENERATORS.map { |generator| kind_for(generator) }.freeze
  end
end
