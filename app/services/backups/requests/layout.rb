module Backups
  module Requests
    class Layout
      HEADER_BACKGROUND = { red: 0.92, green: 0.94, blue: 0.96 }.freeze

      def initialize(sheet_ids:)
        @sheet_ids = sheet_ids
      end

      def call
        Tabs::ALL.filter_map { |tab| requests_for(tab, @sheet_ids[tab.title]) }.flatten
      end

      private

      def requests_for(tab, sheet_id)
        return nil unless sheet_id

        [freeze_header(sheet_id), header_style(sheet_id, tab), column_formats(sheet_id, tab), auto_resize(sheet_id, tab)].flatten
      end

      def freeze_header(sheet_id)
        Google::Apis::SheetsV4::Request.new(
          update_sheet_properties: Google::Apis::SheetsV4::UpdateSheetPropertiesRequest.new(
            properties: Google::Apis::SheetsV4::SheetProperties.new(
              sheet_id:        sheet_id,
              grid_properties: Google::Apis::SheetsV4::GridProperties.new(frozen_row_count: 1)
            ),
            fields:     'gridProperties.frozenRowCount'
          )
        )
      end

      def header_style(sheet_id, tab)
        Google::Apis::SheetsV4::Request.new(
          repeat_cell: Google::Apis::SheetsV4::RepeatCellRequest.new(
            range:  grid_range(sheet_id, start_row: 0, end_row: 1, start_column: 0, end_column: tab.width),
            cell:   Google::Apis::SheetsV4::CellData.new(
              user_entered_format: Google::Apis::SheetsV4::CellFormat.new(
                text_format:      Google::Apis::SheetsV4::TextFormat.new(bold: true),
                background_color: Google::Apis::SheetsV4::Color.new(**HEADER_BACKGROUND)
              )
            ),
            fields: 'userEnteredFormat(textFormat,backgroundColor)'
          )
        )
      end

      def column_formats(sheet_id, tab)
        tab.columns.each_with_index.filter_map do |column, offset|
          next unless column.format

          Google::Apis::SheetsV4::Request.new(
            repeat_cell: Google::Apis::SheetsV4::RepeatCellRequest.new(
              range:  grid_range(sheet_id, start_row: 1, end_row: nil, start_column: offset, end_column: offset + 1),
              cell:   Google::Apis::SheetsV4::CellData.new(
                user_entered_format: Google::Apis::SheetsV4::CellFormat.new(
                  number_format: Google::Apis::SheetsV4::NumberFormat.new(type: column.format.type, pattern: column.format.pattern)
                )
              ),
              fields: 'userEnteredFormat.numberFormat'
            )
          )
        end
      end

      def auto_resize(sheet_id, tab)
        Google::Apis::SheetsV4::Request.new(
          auto_resize_dimensions: Google::Apis::SheetsV4::AutoResizeDimensionsRequest.new(
            dimensions: Google::Apis::SheetsV4::DimensionRange.new(
              sheet_id:    sheet_id,
              dimension:   'COLUMNS',
              start_index: 0,
              end_index:   tab.width
            )
          )
        )
      end

      def grid_range(sheet_id, start_row:, end_row:, start_column:, end_column:)
        Google::Apis::SheetsV4::GridRange.new(
          sheet_id:           sheet_id,
          start_row_index:    start_row,
          end_row_index:      end_row,
          start_column_index: start_column,
          end_column_index:   end_column
        )
      end
    end
  end
end
