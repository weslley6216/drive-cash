module Backups
  class Config
    DEFAULT_SAVINGS_PERCENTAGE = 35

    def service_account_json
      fetch('GOOGLE_BACKUP_SA_JSON')
    end

    def spreadsheet_id
      fetch('GOOGLE_BACKUP_SPREADSHEET_ID')
    end

    def target_email
      fetch('BACKUP_TARGET_EMAIL')
    end

    def savings_percentage
      ENV['BACKUP_SAVINGS_PERCENTAGE'].presence&.to_i || DEFAULT_SAVINGS_PERCENTAGE
    end

    private

    def fetch(key)
      ENV[key].presence || raise(ConfigurationError, "#{key} is not set.")
    end
  end
end
