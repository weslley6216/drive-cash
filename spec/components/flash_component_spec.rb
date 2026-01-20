# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlashComponent, type: :component do
  describe '#view_template' do
    it 'renders nothing when flash is empty' do
      component = FlashComponent.new(flash: {})
      html = view_context.render(component)

      expect(html).to be_empty
    end

    it 'renders success flash message' do
      flash = { notice: 'Operação realizada com sucesso!' }
      component = FlashComponent.new(flash: flash)
      html = view_context.render(component)

      expect(html).to include('bg-green-600')
      expect(html).to include('Operação realizada com sucesso!')
      expect(html).to include('data-controller="flash"')
    end

    it 'renders error flash message' do
      flash = { alert: 'Erro ao processar' }
      component = FlashComponent.new(flash: flash)
      html = view_context.render(component)

      expect(html).to include('bg-red-600')
      expect(html).to include('Erro ao processar')
    end

    it 'renders multiple flash messages' do
      flash = { notice: 'Sucesso!', alert: 'Atenção!' }
      component = FlashComponent.new(flash: flash)
      html = view_context.render(component)

      expect(html).to include('Sucesso!')
      expect(html).to include('Atenção!')
    end

    it 'renders with animate-slide-down class' do
      flash = { notice: 'Test' }
      component = FlashComponent.new(flash: flash)
      html = view_context.render(component)

      expect(html).to include('animate-slide-down')
    end

    it 'renders blue for unknown flash type' do
      flash = { info: 'Informação' }
      component = FlashComponent.new(flash: flash)
      html = view_context.render(component)

      expect(html).to include('bg-blue-600')
      expect(html).to include('Informação')
    end
  end
end
