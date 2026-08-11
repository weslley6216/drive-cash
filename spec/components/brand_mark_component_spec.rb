require 'rails_helper'

RSpec.describe BrandMarkComponent, type: :component do
  it 'renders the wordmark and subtitle by default' do
    html = view_context.render(described_class.new)

    expect(html).to include(I18n.t('brand_mark_component.title'))
    expect(html).to include(I18n.t('brand_mark_component.subtitle'))
  end

  it 'renders the icon without the wordmark when size: :sm' do
    html = view_context.render(described_class.new(size: :sm))

    expect(html).to include('w-9 h-9 rounded-lg')
    expect(html).not_to include(I18n.t('brand_mark_component.title'))
  end

  it 'renders icon w-11 h-11 with text-xl wordmark when size: :md' do
    html = view_context.render(described_class.new(size: :md))

    expect(html).to include('w-11 h-11 rounded-xl')
    expect(html).to include('text-xl')
    expect(html).to include(I18n.t('brand_mark_component.title'))
  end

  it 'renders icon w-14 h-14 with text-2xl wordmark when size: :lg' do
    html = view_context.render(described_class.new(size: :lg))

    expect(html).to include('w-14 h-14 rounded-2xl')
    expect(html).to include('text-2xl')
  end

  it 'uses white background and white text for dark surfaces when light: true' do
    html = view_context.render(described_class.new(light: true))

    expect(html).to include('bg-white')
    expect(html).to include('text-white')
    expect(html).to include('text-blue-100')
  end

  it 'uses blue background and slate text for light surfaces when light: false (default)' do
    html = view_context.render(described_class.new)

    expect(html).to include('bg-blue-600')
    expect(html).to include('text-slate-900')
    expect(html).to include('text-slate-500')
  end

  it 'omits the wordmark even with size :md when wordmark: false' do
    html = view_context.render(described_class.new(size: :md, wordmark: false))

    expect(html).not_to include(I18n.t('brand_mark_component.title'))
  end
end
