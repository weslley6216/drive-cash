require 'rails_helper'

RSpec.describe StatCardComponent, type: :component do
  describe '#view_template' do
    it 'renders title and value' do
      html = view_context.render(described_class.new(title: 'Ganhos', value: 'R$ 100,00', color: :green, icon: PhlexIcons::Lucide::DollarSign))

      expect(html).to include('Ganhos')
      expect(html).to include('R$ 100,00')
    end

    it 'renders subtitle when provided' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', subtitle: 'Sub', color: :green, icon: PhlexIcons::Lucide::DollarSign))

      expect(html).to include('Sub')
    end

    it 'renders as link when href is provided' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: PhlexIcons::Lucide::DollarSign, href: '/test'))

      expect(html).to include('<a')
      expect(html).to include('href="/test"')
    end

    it 'renders as div when href is absent' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: PhlexIcons::Lucide::DollarSign))

      expect(html).not_to include('<a')
    end

    it 'renders without icon when icon is nil' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('T')
    end

    it 'uses large value text by default' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('text-xl')
    end

    it 'uses smaller value text with size: :sm' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil, size: :sm))

      expect(html).to include('text-sm')
      expect(html).not_to include('text-2xl')
    end
  end
end
