require 'rails_helper'

RSpec.describe Backups::SheetWriter do
  let(:client) { instance_double(Google::Apis::SheetsV4::SheetsService) }
  let(:spreadsheet_id) { '1AbC' }
  let(:rows) { { earnings: [['2026-01-02', 'iFood', 50.0, 1, nil, '2026-01-02 10:00:00']] } }

  def sheet(title, sheet_id, charts: [], banded_ranges: [])
    Google::Apis::SheetsV4::Sheet.new(
      properties:    Google::Apis::SheetsV4::SheetProperties.new(sheet_id: sheet_id, title: title),
      charts:        charts,
      banded_ranges: banded_ranges
    )
  end

  def spreadsheet(sheets)
    Google::Apis::SheetsV4::Spreadsheet.new(sheets: sheets)
  end

  def add_sheet_reply(title, sheet_id)
    Google::Apis::SheetsV4::Response.new(
      add_sheet: Google::Apis::SheetsV4::AddSheetResponse.new(
        properties: Google::Apis::SheetsV4::SheetProperties.new(sheet_id: sheet_id, title: title)
      )
    )
  end

  def full_spreadsheet
    spreadsheet(Backups::Tabs::ALL.each_with_index.map { |tab, offset| sheet(tab.title, offset + 100) })
  end

  let(:writer) { described_class.new(client: client, spreadsheet_id: spreadsheet_id, rows: rows, summary_month_count: 0) }

  before do
    allow(client).to receive(:batch_clear_values)
    allow(client).to receive(:batch_update_values)
    allow(client).to receive(:batch_update_spreadsheet)
      .and_return(Google::Apis::SheetsV4::BatchUpdateSpreadsheetResponse.new(replies: []))
  end

  describe '#call' do
    context 'when every tab already exists' do
      before { allow(client).to receive(:get_spreadsheet).and_return(full_spreadsheet) }

      it 'reads only the fields it needs from the spreadsheet' do
        writer.call

        expect(client).to have_received(:get_spreadsheet).with(spreadsheet_id, fields: described_class::FIELDS)
      end

      it 'does not request any new sheet' do
        writer.call

        expect(client).to have_received(:batch_update_spreadsheet).once
      end

      it 'clears the data range of every tab before writing' do
        writer.call

        expect(client).to have_received(:batch_clear_values) do |_id, request|
          expect(request.ranges).to eq(Backups::Tabs::ALL.map { |tab| "'#{tab.title}'!A2:ZZ" })
        end
      end

      it 'writes the header followed by the data rows starting at A1' do
        writer.call

        expect(client).to have_received(:batch_update_values) do |_id, request|
          earnings = request.data.find { |range| range.range == "'Ganhos'!A1" }
          expect(earnings.values.first).to eq(Backups::Tabs.find(:earnings).headers)
          expect(earnings.values.last).to eq(['2026-01-02', 'iFood', 50.0, 1, nil, '2026-01-02 10:00:00'])
        end
      end

      it 'lets the spreadsheet parse the written values' do
        writer.call

        expect(client).to have_received(:batch_update_values) do |_id, request|
          expect(request.value_input_option).to eq('USER_ENTERED')
        end
      end

      it 'writes a header-only tab when there are no rows for it' do
        writer.call

        expect(client).to have_received(:batch_update_values) do |_id, request|
          metas = request.data.find { |range| range.range == "'Metas'!A1" }
          expect(metas.values).to eq([Backups::Tabs.find(:goals).headers])
        end
      end

      it 'applies layout and decoration requests in a single batch' do
        writer.call

        expect(client).to have_received(:batch_update_spreadsheet) do |_id, request|
          expect(request.requests.filter_map(&:update_sheet_properties)).not_to be_empty
          expect(request.requests.filter_map(&:add_banding)).not_to be_empty
        end
      end
    end

    context 'when a tab is missing' do
      before do
        allow(client).to receive(:get_spreadsheet).and_return(spreadsheet([sheet('Resumo', 100)]))
        allow(client).to receive(:batch_update_spreadsheet).and_return(
          Google::Apis::SheetsV4::BatchUpdateSpreadsheetResponse.new(
            replies: Backups::Tabs::ALL.drop(1).each_with_index.map { |tab, offset| add_sheet_reply(tab.title, offset + 200) }
          ),
          Google::Apis::SheetsV4::BatchUpdateSpreadsheetResponse.new(replies: [])
        )
      end

      it 'creates the missing tabs before writing values' do
        writer.call

        expect(client).to have_received(:batch_update_spreadsheet).twice
      end

      it 'decorates the freshly created tabs using the ids returned by the api' do
        writer.call

        expect(client).to have_received(:batch_update_spreadsheet).with(spreadsheet_id, an_object_satisfying { |request|
          request.requests.filter_map(&:add_banding).map { |banding| banding.banded_range.range.sheet_id }.include?(200)
        })
      end
    end

    context 'when the tabs already carry banding and a chart' do
      before do
        allow(client).to receive(:get_spreadsheet).and_return(
          spreadsheet(Backups::Tabs::ALL.each_with_index.map do |tab, offset|
            sheet(tab.title, offset + 100,
                  charts:        tab.key == :summary ? [Google::Apis::SheetsV4::EmbeddedChart.new(chart_id: 9)] : [],
                  banded_ranges: [Google::Apis::SheetsV4::BandedRange.new(banded_range_id: offset)])
          end)
        )
      end

      it 'requests neither banding nor chart again' do
        described_class.new(client: client, spreadsheet_id: spreadsheet_id, rows: rows, summary_month_count: 3).call

        expect(client).to have_received(:batch_update_spreadsheet) do |_id, request|
          expect(request.requests.filter_map(&:add_banding)).to eq([])
          expect(request.requests.filter_map(&:add_chart)).to eq([])
        end
      end
    end

    context 'when the spreadsheet reports no sheets at all' do
      before do
        allow(client).to receive(:get_spreadsheet).and_return(Google::Apis::SheetsV4::Spreadsheet.new(sheets: nil))
        allow(client).to receive(:batch_update_spreadsheet).and_return(
          Google::Apis::SheetsV4::BatchUpdateSpreadsheetResponse.new(
            replies: Backups::Tabs::ALL.each_with_index.map { |tab, offset| add_sheet_reply(tab.title, offset + 300) }
          ),
          Google::Apis::SheetsV4::BatchUpdateSpreadsheetResponse.new(replies: [])
        )
      end

      it 'creates every tab from scratch' do
        writer.call

        expect(client).to have_received(:batch_update_spreadsheet).with(spreadsheet_id, an_object_satisfying { |request|
          request.requests.filter_map(&:add_sheet).map { |added| added.properties.title } == Backups::Tabs::ALL.map(&:title)
        })
      end
    end
  end
end
