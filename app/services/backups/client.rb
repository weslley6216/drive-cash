module Backups
  class Client
    SCOPE = 'https://www.googleapis.com/auth/spreadsheets'.freeze
    APPLICATION_NAME = 'DriveCash Backup'.freeze

    def self.build(config: Config.new)
      new(config: config).build
    end

    def initialize(config:)
      @config = config
    end

    def build
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorizer
      service
    end

    private

    def authorizer
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(@config.service_account_json),
        scope:       SCOPE
      )
    end
  end
end
