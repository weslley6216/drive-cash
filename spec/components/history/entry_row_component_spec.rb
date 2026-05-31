require 'rails_helper'

RSpec.describe History::EntryRowComponent, type: :component do
  let(:context) { { year: 2025, month: nil, q: nil, filter: 'all' } }

  context 'with an earning' do
    let(:earning) { create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', trips_count: 3, notes: 'Madrugada') }
    let(:html)    { view_context.render(described_class.new(record: earning, context: context)) }

    it 'renders the platform label from i18n' do
      expect(html).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'shows the amount with + prefix and emerald color' do
      expect(html).to include('+ R$')
      expect(html).to include('200,00')
      expect(html).to include('text-emerald-700')
    end

    it 'links to the earning edit path inside the modal turbo frame' do
      expect(html).to include(%(href="/earnings/#{earning.id}/edit))
      expect(html).to include('data-turbo-frame="modal"')
    end

    it 'shows the trips description when notes is blank' do
      bare = create(:earning, date: Date.new(2025, 6, 10), amount: 100, platform: 'ifood', trips_count: 2, notes: nil)
      bare_html = view_context.render(described_class.new(record: bare, context: context))

      expect(bare_html).to include(I18n.t('common.trips', count: 2))
    end

    it 'shows notes as description when present' do
      expect(html).to include('Madrugada')
    end
  end

  context 'with a paid expense' do
    let(:expense) { create(:expense, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true) }
    let(:html)    { view_context.render(described_class.new(record: expense, context: context)) }

    it 'renders the category label from i18n' do
      expect(html).to include(I18n.t('activerecord.attributes.expense.categories.fuel'))
    end

    it 'shows the amount with − prefix and red color' do
      expect(html).to include('− R$')
      expect(html).to include('80,00')
      expect(html).to include('text-red-700')
    end

    it 'links to the expense edit path inside the modal turbo frame' do
      expect(html).to include(%(href="/expenses/#{expense.id}/edit))
      expect(html).to include('data-turbo-frame="modal"')
    end

    it 'falls back to expense description when vendor is blank' do
      bare = create(:expense, date: Date.new(2025, 6, 11), amount: 30, category: 'meals', vendor: nil, description: 'Lanche', paid: true)
      bare_html = view_context.render(described_class.new(record: bare, context: context))

      expect(bare_html).to include('Lanche')
    end

    it 'does not render the pending badge for paid expenses' do
      expect(html).not_to include(I18n.t('history.index.day_group.unpaid_badge'))
    end
  end

  context 'with an unpaid expense' do
    let(:expense) { create(:expense, date: Date.new(2025, 6, 12), amount: 120, category: 'maintenance', vendor: 'Pneus', paid: false) }
    let(:html)    { view_context.render(described_class.new(record: expense, context: context)) }

    it 'renders the pending badge with amber styling' do
      expect(html).to include(I18n.t('history.index.day_group.unpaid_badge'))
      expect(html).to include('bg-amber-100')
      expect(html).to include('text-amber-700')
      expect(html).to include('border-amber-200')
    end
  end
end
