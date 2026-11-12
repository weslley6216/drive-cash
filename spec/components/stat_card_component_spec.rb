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

    it 'sizes the value like the prototype MiniStat on phones and DesktopStatCard on desktops' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('text-lg lg:text-2xl font-bold mt-0.5 lg:mt-1.5')
      expect(html).to include('truncate')
    end

    it 'uses smaller value text with size: :sm' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil, size: :sm))

      expect(html).to include('text-sm lg:text-xl')
      expect(html).not_to include('text-lg lg:text-2xl')
    end

    it 'uses the prototype card chrome with a wider desktop padding' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('border-2 rounded-xl p-3 lg:p-4')
      expect(html).not_to include('shadow-sm')
    end

    it 'paints the green card with the emerald palette of the prototype' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('bg-emerald-50 border-emerald-200')
      expect(html).to include('text-emerald-900')
    end

    it 'shows a small title on phones and an uppercase caption on desktops' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('text-xs font-medium opacity-75 lg:font-semibold lg:uppercase lg:tracking-wide lg:opacity-80')
    end

    it 'swaps to the short title on phones when one is given' do
      html = view_context.render(described_class.new(title: 'Dias trabalhados', short_title: 'Dias', value: 'V', color: :yellow, icon: nil))

      expect(html).to include('<span class="lg:hidden">Dias</span>')
      expect(html).to include('<span class="hidden lg:inline">Dias trabalhados</span>')
    end
  end
end
