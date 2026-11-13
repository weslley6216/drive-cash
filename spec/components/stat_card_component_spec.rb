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

    it 'keeps the original phone value size and the prototype desktop size' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('text-xl lg:text-2xl font-bold mt-1 lg:mt-1.5')
      expect(html).to include('truncate')
    end

    it 'uses smaller value text with size: :sm' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil, size: :sm))

      expect(html).to include('text-sm lg:text-xl')
      expect(html).not_to include('text-xl lg:text-2xl')
    end

    it 'keeps the original phone card shadow and the flat wider desktop card' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('border-2 rounded-xl p-3 shadow-sm lg:p-4 lg:shadow-none')
    end

    it 'paints the green card with the emerald palette of the prototype' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: nil))

      expect(html).to include('bg-emerald-50 border-emerald-200')
      expect(html).to include('text-emerald-900')
    end

    it 'shows the original phone title and an uppercase caption on desktops' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', subtitle: 'S', color: :green, icon: nil))

      expect(html).to include('text-sm font-medium opacity-75 lg:text-xs lg:font-semibold lg:uppercase lg:tracking-wide lg:opacity-80')
      expect(html).to include('text-xs mt-1 opacity-60 lg:opacity-70 truncate col-span-2 lg:col-span-1')
    end

    it 'puts the icon on the title row on phones and beside the whole block on desktops' do
      html = view_context.render(described_class.new(title: 'T', value: 'V', color: :green, icon: PhlexIcons::Lucide::DollarSign))

      expect(html).to include('grid grid-cols-[minmax(0,1fr)_auto] items-start gap-x-2 lg:gap-x-3')
      expect(html).to include('row-start-1 col-start-2 lg:row-span-3')
      expect(html).to include('truncate col-span-2 lg:col-span-1')
    end

    it 'swaps to the short title on phones when one is given' do
      html = view_context.render(described_class.new(title: 'Dias trabalhados', short_title: 'Dias', value: 'V', color: :yellow, icon: nil))

      expect(html).to include('<span class="lg:hidden">Dias</span>')
      expect(html).to include('<span class="hidden lg:inline">Dias trabalhados</span>')
    end
  end
end
