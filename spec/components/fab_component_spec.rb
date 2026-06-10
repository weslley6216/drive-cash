require 'rails_helper'

RSpec.describe FabComponent, type: :component do
  let(:filters) { { year: 2025, month: 12 } }
  let(:component) { FabComponent.new(filters: filters) }
  let(:html) { view_context.render(component) }

  describe '#view_template' do
    it 'renders container with correct controller and position' do
      expect(html).to include('data-controller="fab"')
      expect(html).to include('fixed bottom-6 right-6')
      expect(html).to include('z-40')
    end

    it 'renders main button with blue color' do
      expect(html).to include('bg-blue-600')
      expect(html).to include('data-action="fab#toggle"')
      expect(html).to include('data-fab-target="button"')
    end

    it 'renders menu container hidden by default' do
      expect(html).to include('data-fab-target="menu"')
      expect(html).to include('hidden')
      expect(html).to include('flex-col items-end')
    end

    it 'renders journey button linking to work_session with sky color' do
      expect(html).to include(I18n.t('fab_component.start_journey'))
      expect(html).to include('bg-sky-600')
      expect(html).to include('hover:bg-sky-700')
      expect(html).to include('href="/work_session"')
    end

    it 'renders expense button with red color' do
      expect(html).to include(I18n.t('fab_component.new_expense'))
      expect(html).to include('bg-red-600')
      expect(html).to include('hover:bg-red-700')
    end

    it 'renders earning button with emerald color' do
      expect(html).to include(I18n.t('fab_component.new_earning'))
      expect(html).to include('bg-emerald-600')
      expect(html).to include('hover:bg-emerald-700')
    end

    it 'renders correct links with filter context' do
      expect(html).to include('context%5Byear%5D=2025')
      expect(html).to include('context%5Bmonth%5D=12')
      expect(html).to include('/records/new')
      expect(html).to include('type=earning')
      expect(html).to include('type=expense')
    end

    it 'renders without filters when empty' do
      html = view_context.render(FabComponent.new(filters: {}))

      expect(html).to include('/records/new')
      expect(html).to include('type=earning')
      expect(html).not_to include('context%5Byear%5D=2025')
    end

    it 'sets turbo-frame=_top on all navigation links so they escape the page frame' do
      expect(html.scan('data-turbo-frame="_top"').size).to eq(4)
    end
  end

  describe 'with bottom_nav: true' do
    let(:component) { FabComponent.new(filters: filters, bottom_nav: true) }
    let(:html) { view_context.render(component) }

    it 'positions container at bottom-24 instead of bottom-6' do
      expect(html).to include('fixed bottom-24 right-6')
      expect(html).not_to include('fixed bottom-6 right-6')
    end
  end
end
