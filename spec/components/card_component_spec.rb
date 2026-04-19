require 'rails_helper'

RSpec.describe CardComponent, type: :component do
  describe '#view_template' do
    it 'renders a card with default styling' do
      html = CardComponent.new.call { 'Card content' }

      expect(html).to include('<div')
      expect(html).to include('bg-white')
      expect(html).to include('rounded-lg')
      expect(html).to include('shadow-md')
      expect(html).to include('p-6')
      expect(html).to include('Card content')
    end

    it 'renders without padding when padding: false' do
      html = CardComponent.new(padding: false).call { 'Content' }

      expect(html).not_to include('p-6')
    end

    it 'renders without shadow when shadow: false' do
      html = CardComponent.new(shadow: false).call { 'Content' }

      expect(html).not_to include('shadow')
    end

    it 'renders with small shadow' do
      html = CardComponent.new(shadow: :sm).call { 'Content' }

      expect(html).to include('shadow-sm')
    end

    it 'renders with medium shadow' do
      html = CardComponent.new(shadow: :md).call { 'Content' }

      expect(html).to include('shadow-md')
    end

    it 'renders with large shadow' do
      html = CardComponent.new(shadow: :lg).call { 'Content' }

      expect(html).to include('shadow-lg')
    end

    it 'renders with extra large shadow' do
      html = CardComponent.new(shadow: :xl).call { 'Content' }

      expect(html).to include('shadow-xl')
    end

    it 'merges custom classes' do
      html = CardComponent.new(class: 'max-w-md').call { 'Content' }

      expect(html).to include('max-w-md')
      expect(html).to include('bg-white')
    end

    it 'passes custom attributes' do
      html = CardComponent.new(id: 'my-card', data: { controller: 'card' }).call { 'Content' }

      expect(html).to include('id="my-card"')
      expect(html).to include('data-controller="card"')
    end
  end
end
