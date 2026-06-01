require 'rails_helper'

RSpec.describe Records::StickyActionBarComponent, type: :component do
  it 'renders red CTA when theme is red' do
    html = view_context.render(described_class.new(theme: :red))

    expect(html).to include('bg-red-600')
    expect(html).to include(I18n.t('records.new_view.save_expense'))
  end

  it 'renders emerald CTA when theme is emerald' do
    html = view_context.render(described_class.new(theme: :emerald))

    expect(html).to include('bg-emerald-600')
    expect(html).to include(I18n.t('records.new_view.save_earning'))
  end

  it 'is positioned at bottom with sticky border' do
    html = view_context.render(described_class.new(theme: :red))

    expect(html).to include('border-t border-slate-100 bg-white')
  end

  it 'exposes Stimulus target for theming' do
    html = view_context.render(described_class.new(theme: :red))

    expect(html).to include('data-record-form-target="submit"')
  end
end
