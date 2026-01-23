# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabComponent, type: :component do
  let(:filters) { { year: 2025, month: 12 } }

  describe '#view_template' do
    it 'renders container with correct controller and position' do
      component = FabComponent.new(filters: filters)
      html = view_context.render(component)

      expect(html).to include('data-controller="fab"')
      expect(html).to include('fixed bottom-6 right-6')
      expect(html).to include('z-40')
    end

    it 'renders main button with blue color' do
      component = FabComponent.new(filters: filters)
      html = view_context.render(component)

      expect(html).to include('bg-blue-600')
      expect(html).to include('data-action="fab#toggle"')
      expect(html).to include('data-fab-target="button"')
    end

    it 'renders menu container hidden by default' do
      component = FabComponent.new(filters: filters)
      html = view_context.render(component)

      expect(html).to include('data-fab-target="menu"')
      expect(html).to include('hidden')
      expect(html).to include('flex-col items-end')
    end

    it 'renders expense button with red color' do
      component = FabComponent.new(filters: filters)
      html = view_context.render(component)

      expect(html).to include('Despesa Avulsa')
      expect(html).to include('bg-red-600')
      expect(html).to include('hover:bg-red-700')
    end

    it 'renders close day button with emerald color' do
      component = FabComponent.new(filters: filters)
      html = view_context.render(component)

      expect(html).to include('Fechar o Dia')
      expect(html).to include('bg-emerald-600')
      expect(html).to include('hover:bg-emerald-700')
    end

    it 'renders correct links with filter context' do
      component = FabComponent.new(filters: filters)
      html = view_context.render(component)

      # Verifica se os parâmetros foram codificados na URL
      expect(html).to include('context%5Byear%5D=2025')
      expect(html).to include('context%5Bmonth%5D=12')
      expect(html).to include('/trips/new')
      expect(html).to include('/expenses/new')
    end

    it 'renders without filters when empty' do
      component = FabComponent.new(filters: {})
      html = view_context.render(component)

      expect(html).to include('/trips/new')
      expect(html).not_to include('context%5Byear%5D=2025')
    end
  end
end
