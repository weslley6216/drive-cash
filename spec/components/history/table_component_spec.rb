require 'rails_helper'

RSpec.describe History::TableComponent, type: :component do
  let(:context) { { year: 2026, month: 5, q: nil, filter: 'all' } }
  let(:earning) { create(:earning, date: Date.current, amount: 32.5, platform: 'uber', trips_count: 1) }
  let(:unpaid) { create(:expense, date: Date.current - 2, amount: 35, category: 'car_wash', vendor: 'Lava-rápido', paid: false) }
  let(:paid) { create(:expense, date: Date.current - 1, amount: 60, category: 'fuel', vendor: 'Posto Orense', paid: true) }
  let(:groups) do
    [
      { date: Date.current, items: [earning] },
      { date: Date.current - 1, items: [paid] },
      { date: Date.current - 2, items: [unpaid] }
    ]
  end
  let(:html) { view_context.render(described_class.new(groups: groups, context: context)) }

  it 'heads the columns in the design order' do
    headers = %w[date type description status amount].map { |column| I18n.t("history.index.table.#{column}") }

    expect(html.scan(%r{<th[^>]*>([^<]+)</th>}).flatten).to eq(headers)
  end

  it 'dates today, yesterday and older rows' do
    expect(html).to include(">#{I18n.t('common.today')}<")
    expect(html).to include(">#{I18n.t('common.yesterday')}<")
    expect(html).to include(">#{I18n.l(Date.current - 2, format: '%-d/%b')}<")
  end

  it 'tags each row status' do
    expect(html).to include(I18n.t('history.index.status.earning'))
    expect(html).to include(I18n.t('history.index.status.paid'))
    expect(html).to include(I18n.t('history.index.day_group.unpaid_badge'))
  end

  it 'signs and colors the amounts' do
    expect(html).to include('+R$ 32,50')
    expect(html).to include('−R$ 60,00')
  end

  it 'links each row to its edit modal' do
    expect(html).to include(%(href="/earnings/#{earning.id}/edit))
    expect(html).to include(%(aria-label="#{I18n.t('history.index.edit.expense')}"))
  end
end
