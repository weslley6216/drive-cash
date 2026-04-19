require 'rails_helper'

RSpec.describe ButtonComponent, type: :component do
  describe '#view_template' do
    it 'renders a button with primary variant by default' do
      html = ButtonComponent.new.call { 'Click me' }

      expect(html).to include('<button')
      expect(html).to include('bg-blue-600')
      expect(html).to include('Click me')
    end

    it 'renders secondary variant' do
      html = ButtonComponent.new(variant: :secondary).call { 'Secondary' }

      expect(html).to include('bg-gray-200')
      expect(html).to include('Secondary')
    end

    it 'renders danger variant' do
      html = ButtonComponent.new(variant: :danger).call { 'Delete' }

      expect(html).to include('bg-red-600')
      expect(html).to include('Delete')
    end

    it 'renders success variant' do
      html = ButtonComponent.new(variant: :success).call { 'Save' }

      expect(html).to include('bg-green-600')
      expect(html).to include('Save')
    end

    it 'falls back to default styles for unknown variant' do
      html = ButtonComponent.new(variant: :unknown).call { 'Unknown' }

      expect(html).to include('bg-gray-100')
      expect(html).to include('hover:bg-gray-200')
    end

    it 'renders small size' do
      html = ButtonComponent.new(size: :small).call { 'Small' }

      expect(html).to include('px-3 py-1.5')
      expect(html).to include('text-sm')
    end

    it 'renders medium size by default' do
      html = ButtonComponent.new.call { 'Medium' }

      expect(html).to include('px-4 py-2')
      expect(html).to include('text-base')
    end

    it 'renders large size' do
      html = ButtonComponent.new(size: :large).call { 'Large' }

      expect(html).to include('px-6 py-3')
      expect(html).to include('text-lg')
    end

    it 'merges custom classes' do
      html = ButtonComponent.new(class: 'custom-class').call { 'Custom' }

      expect(html).to include('custom-class')
      expect(html).to include('bg-blue-600')
    end

    it 'falls back to default size for unknown size' do
      html = ButtonComponent.new(size: :unknown).call { 'Unknown size' }

      expect(html).to include('px-4 py-2')
    end

    it 'passes custom attributes' do
      html = ButtonComponent.new(type: 'submit', disabled: true).call { 'Submit' }

      expect(html).to include('type="submit"')
      expect(html).to include('disabled')
    end
  end
end
