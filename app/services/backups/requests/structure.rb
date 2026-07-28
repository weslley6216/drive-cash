module Backups
  module Requests
    class Structure
      State = Data.define(:sheet_ids, :banded_titles, :chart_ids)

      CHART_COLUMN_GAP = 2
      FIRST_BAND_COLOR = { red: 1.0, green: 1.0, blue: 1.0 }.freeze
      SECOND_BAND_COLOR = { red: 0.97, green: 0.98, blue: 0.99 }.freeze

      def initialize(state:, summary_month_count:)
        @state = state
        @summary_month_count = summary_month_count
      end

      def missing_tabs
        Tabs::ALL.reject { |tab| @state.sheet_ids.key?(tab.title) }.map { |tab| add_sheet(tab) }
      end

      def decorations
        Tabs::ALL.filter_map { |tab| banding_for(tab) } + [chart].compact
      end

      private

      def add_sheet(tab)
        Google::Apis::SheetsV4::Request.new(
          add_sheet: Google::Apis::SheetsV4::AddSheetRequest.new(
            properties: Google::Apis::SheetsV4::SheetProperties.new(title: tab.title, index: Tabs::ALL.index(tab))
          )
        )
      end

      def banding_for(tab)
        sheet_id = @state.sheet_ids[tab.title]
        return nil if sheet_id.nil? || @state.banded_titles.include?(tab.title)

        Google::Apis::SheetsV4::Request.new(
          add_banding: Google::Apis::SheetsV4::AddBandingRequest.new(
            banded_range: Google::Apis::SheetsV4::BandedRange.new(
              range:          Google::Apis::SheetsV4::GridRange.new(sheet_id: sheet_id, start_column_index: 0, end_column_index: tab.width),
              row_properties: Google::Apis::SheetsV4::BandingProperties.new(
                header_color:      Google::Apis::SheetsV4::Color.new(**HEADER_COLOR),
                first_band_color:  Google::Apis::SheetsV4::Color.new(**FIRST_BAND_COLOR),
                second_band_color: Google::Apis::SheetsV4::Color.new(**SECOND_BAND_COLOR)
              )
            )
          )
        )
      end

      def chart
        tab = Tabs.find(:summary)
        sheet_id = @state.sheet_ids[tab.title]
        return nil if sheet_id.nil? || @summary_month_count.zero?

        chart_id = @state.chart_ids[tab.title]
        chart_id ? update_chart(chart_id, sheet_id, tab) : add_chart(sheet_id, tab)
      end

      def add_chart(sheet_id, tab)
        Google::Apis::SheetsV4::Request.new(
          add_chart: Google::Apis::SheetsV4::AddChartRequest.new(
            chart: Google::Apis::SheetsV4::EmbeddedChart.new(spec: chart_spec(sheet_id, tab), position: chart_position(sheet_id, tab))
          )
        )
      end

      def update_chart(chart_id, sheet_id, tab)
        Google::Apis::SheetsV4::Request.new(
          update_chart_spec: Google::Apis::SheetsV4::UpdateChartSpecRequest.new(chart_id: chart_id, spec: chart_spec(sheet_id, tab))
        )
      end

      def chart_spec(sheet_id, tab)
        Google::Apis::SheetsV4::ChartSpec.new(
          title:       I18n.t('backups.summary.chart_title'),
          basic_chart: Google::Apis::SheetsV4::BasicChartSpec.new(
            chart_type:      'COLUMN',
            legend_position: 'BOTTOM_LEGEND',
            domains:         [Google::Apis::SheetsV4::BasicChartDomain.new(domain: chart_data(sheet_id, 0))],
            series:          [Google::Apis::SheetsV4::BasicChartSeries.new(series: chart_data(sheet_id, tab.index_of(:profit)), target_axis: 'LEFT_AXIS')]
          )
        )
      end

      def chart_data(sheet_id, column)
        Google::Apis::SheetsV4::ChartData.new(
          source_range: Google::Apis::SheetsV4::ChartSourceRange.new(
            sources: [
              Google::Apis::SheetsV4::GridRange.new(
                sheet_id:           sheet_id,
                start_row_index:    1,
                end_row_index:      @summary_month_count + 1,
                start_column_index: column,
                end_column_index:   column + 1
              )
            ]
          )
        )
      end

      def chart_position(sheet_id, tab)
        Google::Apis::SheetsV4::EmbeddedObjectPosition.new(
          overlay_position: Google::Apis::SheetsV4::OverlayPosition.new(
            anchor_cell: Google::Apis::SheetsV4::GridCoordinate.new(sheet_id: sheet_id, row_index: 1, column_index: tab.width + CHART_COLUMN_GAP)
          )
        )
      end
    end
  end
end
