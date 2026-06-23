module Chat
  module Answers
    class MaintenanceStatus
      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        maintenances = @data[:maintenances] || []
        urgent = maintenances.select { |row| %w[soon overdue].include?(row.status_key.to_s) }
        return 'Tudo em dia com as manutenções!' if urgent.empty?

        urgent.map { |row| "#{row.maintenance.category.humanize}: #{row.status_key}" }.join(' · ')
      end
    end
  end
end
