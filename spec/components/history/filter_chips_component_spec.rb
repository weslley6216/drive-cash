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

  it 'highlights the active chip with dark styling' do
    new_html = view_context.render(described_class.new(current_filter: 'unpaid', query: nil))

    expect(new_html).to include('bg-slate-800')
    expect(new_html).to include('text-white')
  end

  it 'styles inactive chips with white background' do
    expect(html).to include('bg-white')
    expect(html).to include('border-slate-200')
  end

  it 'renders chips in a horizontally scrollable row' do
    expect(html).to include('overflow-x-auto')
  end
end
