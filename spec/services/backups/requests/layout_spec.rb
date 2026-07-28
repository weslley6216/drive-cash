require 'rails_helper'

RSpec.describe Backups::Requests::Layout do
  let(:sheet_ids) { Backups::Tabs::ALL.each_with_index.to_h { |tab, offset| [tab.title, offset] } }
  let(:requests) { described_class.new(sheet_ids: sheet_ids).call }

  describe '#call' do
    it 'freezes the header row of every tab' do
      frozen = requests.filter_map(&:update_sheet_properties)

      expect(frozen.size).to eq(Backups::Tabs::ALL.size)
      expect(frozen.first.properties.grid_properties.frozen_row_count).to eq(1)
      expect(frozen.first.fields).to eq('gridProperties.frozenRowCount')
    end

    it 'renders the header row in bold over a grey background' do
      header = requests.filter_map(&:repeat_cell).find { |request| request.range.end_row_index == 1 }

      expect(header.cell.user_entered_format.text_format.bold).to be(true)
      expect(header.cell.user_entered_format.background_color.red).to eq(0.92)
      expect(header.fields).to eq('userEnteredFormat(textFormat,backgroundColor)')
    end

    it 'applies the currency format to the amount column of the earnings tab' do
      sheet_id = sheet_ids['Ganhos']
      formats = requests.filter_map(&:repeat_cell).select { |request| request.range.sheet_id == sheet_id && request.range.start_row_index == 1 }
      amount = formats.find { |request| request.range.start_column_index == 2 }

      expect(amount.cell.user_entered_format.number_format.type).to eq('CURRENCY')
      expect(amount.cell.user_entered_format.number_format.pattern).to eq('"R$" #,##0.00')
      expect(amount.fields).to eq('userEnteredFormat.numberFormat')
      expect(amount.range.end_column_index).to eq(3)
    end

    it 'skips columns declared without a number format' do
      sheet_id = sheet_ids['Ganhos']
      columns = requests.filter_map(&:repeat_cell)
        .select { |request| request.range.sheet_id == sheet_id && request.range.start_row_index == 1 }
        .map { |request| request.range.start_column_index }

      expect(columns).to eq([0, 2, 3, 5])
    end

    it 'auto resizes every column of every tab' do
      resize = requests.filter_map(&:auto_resize_dimensions).find { |request| request.dimensions.sheet_id == sheet_ids['Ganhos'] }

      expect(resize.dimensions.dimension).to eq('COLUMNS')
      expect(resize.dimensions.start_index).to eq(0)
      expect(resize.dimensions.end_index).to eq(6)
    end

    it 'ignores tabs whose sheet id is unknown' do
      single_tab = described_class.new(sheet_ids: { 'Ganhos' => 7 }).call

      expect(single_tab.filter_map(&:update_sheet_properties).size).to eq(1)
    end
  end
end
