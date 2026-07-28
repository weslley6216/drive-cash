module Backups
  class SheetWriter
    FIELDS = 'sheets(properties(sheetId,title),charts(chartId),bandedRanges(bandedRangeId))'.freeze
    LAST_COLUMN = 'Z'.freeze

    def initialize(client:, spreadsheet_id:, rows:, summary_month_count:)
      @client = client
      @spreadsheet_id = spreadsheet_id
      @rows = rows
      @summary_month_count = summary_month_count
    end

    def call
      state = create_missing_tabs(load_state)

      write_values
      clear_stale_values
      decorate(state)
    end

    private

    def load_state
      spreadsheet = @client.get_spreadsheet(@spreadsheet_id, fields: FIELDS)
      sheets = spreadsheet.sheets || []

      Requests::Structure::State.new(
        sheet_ids:     sheets.to_h { |sheet| [sheet.properties.title, sheet.properties.sheet_id] },
        banded_titles: sheets.select { |sheet| sheet.banded_ranges.present? }.map { |sheet| sheet.properties.title },
        chart_ids:     sheets.select { |sheet| sheet.charts.present? }
                             .to_h { |sheet| [sheet.properties.title, sheet.charts.first.chart_id] }
      )
    end

    def create_missing_tabs(state)
      requests = structure(state).missing_tabs
      return state if requests.empty?

      response = batch_update(requests)
      created = response.replies.filter_map(&:add_sheet).to_h { |reply| [reply.properties.title, reply.properties.sheet_id] }

      state.with(sheet_ids: state.sheet_ids.merge(created))
    end

    def clear_stale_values
      ranges = Tabs::ALL.map { |tab| "'#{tab.title}'!A#{Array(@rows[tab.key]).size + 2}:#{LAST_COLUMN}" }

      @client.batch_clear_values(@spreadsheet_id, Google::Apis::SheetsV4::BatchClearValuesRequest.new(ranges: ranges))
    end

    def write_values
      data = Tabs::ALL.map do |tab|
        Google::Apis::SheetsV4::ValueRange.new(
          range:  "'#{tab.title}'!A1",
          values: [tab.headers] + Array(@rows[tab.key])
        )
      end

      @client.batch_update_values(
        @spreadsheet_id,
        Google::Apis::SheetsV4::BatchUpdateValuesRequest.new(value_input_option: 'USER_ENTERED', data: data)
      )
    end

    def decorate(state)
      batch_update(Requests::Layout.new(sheet_ids: state.sheet_ids).call + structure(state).decorations)
    end

    def structure(state)
      Requests::Structure.new(state: state, summary_month_count: @summary_month_count)
    end

    def batch_update(requests)
      @client.batch_update_spreadsheet(
        @spreadsheet_id,
        Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: requests)
      )
    end
  end
end
