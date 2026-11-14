require 'rails_helper'

RSpec.describe History::FilterChipsComponent, type: :component do
  let(:html) { view_context.render(described_class.new(current_filter: 'all', query: nil)) }

  it 'renders all four chip labels from i18n' do
    %w[all earnings expenses unpaid].each do |key|
      expect(html).to include(I18n.t("history.index.filters.#{key}"))
    end
  end

  it 'links each chip to /history with its filter param' do
    %w[all earnings expenses unpaid].each do |key|
      expect(html).to include(%(href="#{Rails.application.routes.url_helpers.history_path(filter: key)}"))
    end
  end

  it 'preserves the current query in chip links' do
    new_html = view_context.render(described_class.new(current_filter: 'all', query: 'posto'))

    expect(new_html).to include('q=posto')
  end

  it 'preserves year and month in chip links when provided' do
    new_html = view_context.render(described_class.new(current_filter: 'all', query: nil, year: 2026, month: 5))

    expect(new_html).to include('year=2026')
    expect(new_html).to include('month=5')
  end

  it 'omits year and month from chip links when not provided' do
    expect(html).not_to include('year=')
    expect(html).not_to include('month=')
  end

  it 'highlights the active chip with dark styling' do
    new_html = view_context.render(described_class.new(current_filter: 'unpaid', query: nil))

    expect(new_html).to include('bg-slate-800')
    expect(new_html).to include('text-white')
  end

  it 'adds the active category chip after the type chips, labeled with the category name' do
    new_html = view_context.render(described_class.new(current_filter: 'fuel', query: nil, year: 2026, month: 5))

    chips = Capybara.string(new_html).all('a')
    expect(chips.map(&:text)).to eq(['Todos', 'Receitas', 'Despesas', 'Não pagas', 'Combustível'])
    expect(chips.last[:class]).to include('bg-slate-800 text-white')
    expect(chips.last[:href]).to eq(Rails.application.routes.url_helpers.history_path(filter: 'fuel', year: 2026, month: 5))
  end

  it 'marks only the active chip as the target the chip strip scrolls into view' do
    new_html = view_context.render(described_class.new(current_filter: 'fuel', query: nil, year: 2026, month: 5))

    strip = Capybara.string(new_html).find('div[data-controller="chip-strip"]')
    expect(strip.all('a[data-chip-strip-target="active"]').map(&:text)).to eq(['Combustível'])
  end

  it 'leaves the category chips out while a type filter is active' do
    expect(Capybara.string(html).all('a').map(&:text)).to eq(['Todos', 'Receitas', 'Despesas', 'Não pagas'])
  end

  it 'styles inactive chips with white background' do
    expect(html).to include('bg-white')
    expect(html).to include('border-slate-200')
  end

  it 'renders chips in a horizontally scrollable row' do
    expect(html).to include('overflow-x-auto')
  end
end
