module Backups
  class SheetSync
    class MissingUser < StandardError; end

    def self.call(config: Config.new, client: nil, writer_class: SheetWriter)
      new(config: config, client: client || Client.build(config: config), writer_class: writer_class).call
    end

    def initialize(config:, client:, writer_class:)
      @config = config
      @client = client
      @writer_class = writer_class
    end

    def call
      snapshot = Snapshot.call(user: target_user)
      summary = Summary.new(
        earnings:           snapshot.earnings,
        expenses:           snapshot.expenses,
        savings_percentage: @config.savings_percentage
      ).call

      @writer_class.new(
        client:              @client,
        spreadsheet_id:      @config.spreadsheet_id,
        rows:                snapshot.rows.merge(summary: summary.rows),
        summary_month_count: summary.month_count
      ).call
    end

    private

    def target_user
      User.find_by(email_address: @config.target_email) ||
        raise(MissingUser, "no user with email #{@config.target_email}")
    end
  end
end
