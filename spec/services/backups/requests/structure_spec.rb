require 'rails_helper'

RSpec.describe Backups::Requests::Structure do
  def state(sheet_ids: {}, banded_titles: [], charted_titles: [])
    Backups::Requests::Structure::State.new(sheet_ids: sheet_ids, banded_titles: banded_titles, charted_titles: charted_titles)
  end

  let(:all_ids) { Backups::Tabs::ALL.each_with_index.to_h { |tab, offset| [tab.title, offset] } }

  describe '#missing_tabs' do
    it 'requests one sheet per tab when the spreadsheet is empty' do
      requests = described_class.new(state: state, summary_month_count: 0).missing_tabs

      expect(requests.map { |request| request.add_sheet.properties.title })
        .to eq(['Resumo', 'Ganhos', 'Despesas', 'Abastecimentos', 'Manutenções', 'Metas'])
    end

    it 'requests only the tabs that do not exist yet' do
      requests = described_class.new(state: state(sheet_ids: { 'Resumo' => 1, 'Ganhos' => 2 }), summary_month_count: 0).missing_tabs

      expect(requests.map { |request| request.add_sheet.properties.title })
        .to eq(['Despesas', 'Abastecimentos', 'Manutenções', 'Metas'])
    end

    it 'requests nothing when every tab already exists' do
      requests = described_class.new(state: state(sheet_ids: all_ids), summary_month_count: 0).missing_tabs

      expect(requests).to eq([])
    end
  end

  describe '#decorations' do
    it 'adds banding to every tab that has none' do
      requests = described_class.new(state: state(sheet_ids: all_ids), summary_month_count: 3).decorations
      banded = requests.filter_map(&:add_banding)

      expect(banded.size).to eq(Backups::Tabs::ALL.size)
      expect(banded.first.banded_range.range.sheet_id).to eq(all_ids['Resumo'])
      expect(banded.first.banded_range.row_properties.header_color.red).to eq(0.92)
    end

    it 'skips banding on tabs that already have one' do
      requests = described_class.new(state: state(sheet_ids: all_ids, banded_titles: ['Ganhos']), summary_month_count: 3).decorations
      banded_sheet_ids = requests.filter_map(&:add_banding).map { |request| request.banded_range.range.sheet_id }

      expect(banded_sheet_ids).not_to include(all_ids['Ganhos'])
      expect(banded_sheet_ids).to include(all_ids['Despesas'])
    end

    it 'adds a monthly profit column chart to the summary tab' do
      requests = described_class.new(state: state(sheet_ids: all_ids), summary_month_count: 3).decorations
      chart = requests.filter_map(&:add_chart).first.chart

      expect(chart.spec.title).to eq('Lucro mensal')
      expect(chart.spec.basic_chart.chart_type).to eq('COLUMN')
      expect(chart.position.overlay_position.anchor_cell.sheet_id).to eq(all_ids['Resumo'])
    end

    it 'points the chart at the month rows only, skipping the annual totals' do
      requests = described_class.new(state: state(sheet_ids: all_ids), summary_month_count: 3).decorations
      basic = requests.filter_map(&:add_chart).first.chart.spec.basic_chart

      domain = basic.domains.first.domain.source_range.sources.first
      series = basic.series.first.series.source_range.sources.first

      expect(domain.start_row_index).to eq(1)
      expect(domain.end_row_index).to eq(4)
      expect(domain.start_column_index).to eq(0)
      expect(series.start_column_index).to eq(3)
      expect(series.end_column_index).to eq(4)
    end

    it 'skips the chart when the summary tab already has one' do
      requests = described_class.new(state: state(sheet_ids: all_ids, charted_titles: ['Resumo']), summary_month_count: 3).decorations

      expect(requests.filter_map(&:add_chart)).to eq([])
    end

    it 'skips the chart when there is no month to plot' do
      requests = described_class.new(state: state(sheet_ids: all_ids), summary_month_count: 0).decorations

      expect(requests.filter_map(&:add_chart)).to eq([])
    end

    it 'ignores tabs whose sheet id is unknown' do
      requests = described_class.new(state: state(sheet_ids: { 'Ganhos' => 7 }), summary_month_count: 3).decorations

      expect(requests.size).to eq(1)
    end
  end
end
