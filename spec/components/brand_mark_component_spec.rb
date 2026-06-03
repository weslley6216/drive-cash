require 'rails_helper'

RSpec.describe BrandMarkComponent, type: :component do
  it 'renders the wordmark and subtitle by default' do
    html = view_context.render(described_class.new)

    expect(html).to include(I18n.t('brand_mark_component.title'))
    expect(html).to include(I18n.t('brand_mark_component.subtitle'))
  end

  context 'when size: :sm' do
    it 'renders the icon without the wordmark' do
      html = view_context.render(described_class.new(size: :sm))

      expect(html).to include('w-9 h-9 rounded-lg')
      expect(html).not_to include(I18n.t('brand_mark_component.title'))
    end
  end

  context 'when size: :md' do
    it 'renders icon w-11 h-11 with text-xl wordmark' do
      html = view_context.render(described_class.new(size: :md))

      expect(html).to include('w-11 h-11 rounded-xl')
      expect(html).to include('text-xl')
      expect(html).to include(I18n.t('brand_mark_component.title'))
    end
  end

  context 'when size: :lg' do
    it 'renders icon w-14 h-14 with text-2xl wordmark' do
      html = view_context.render(described_class.new(size: :lg))

      expect(html).to include('w-14 h-14 rounded-2xl')
      expect(html).to include('text-2xl')
    end
  end

  context 'when light: true' do
    it 'uses white background and white text for dark surfaces' do
      html = view_context.render(described_class.new(light: true))

      expect(html).to include('bg-white')
      expect(html).to include('text-white')
      expect(html).to include('text-blue-100')
    end
  end

  context 'when light: false (default)' do
    it 'uses blue background and slate text for light surfaces' do
      html = view_context.render(described_class.new)

      expect(html).to include('bg-blue-600')
      expect(html).to include('text-slate-900')
      expect(html).to include('text-slate-500')
    end
  end

  context 'when wordmark: false' do
    it 'omits the wordmark even with size :md' do
      html = view_context.render(described_class.new(size: :md, wordmark: false))

      expect(html).not_to include(I18n.t('brand_mark_component.title'))
    end
  end
end
