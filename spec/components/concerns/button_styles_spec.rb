# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ButtonStyles do
  let(:test_class) do
    Class.new do
      include ButtonStyles
    end
  end

  let(:instance) { test_class.new }

  describe '#button_classes' do
    it 'returns primary button classes by default' do
      result = instance.button_classes

      expect(result).to include('bg-blue-600')
      expect(result).to include('text-white')
      expect(result).to include('hover:bg-blue-700')
      expect(result).to include('px-4 py-2')
      expect(result).to include('rounded-lg')
    end

    it 'returns secondary button classes' do
      result = instance.button_classes(variant: :secondary)

      expect(result).to include('border border-slate-300')
      expect(result).to include('text-slate-700')
      expect(result).to include('hover:bg-slate-50')
    end

    it 'returns danger button classes' do
      result = instance.button_classes(variant: :danger)

      expect(result).to include('bg-red-600')
      expect(result).to include('text-white')
      expect(result).to include('hover:bg-red-700')
    end

    it 'adds full width class when requested' do
      result = instance.button_classes(full_width: true)

      expect(result).to include('w-full')
    end

    it 'does not add width class when not requested' do
      result = instance.button_classes(full_width: false)

      expect(result).not_to include('w-full')
    end

    it 'falls back to primary for unknown variant' do
      result = instance.button_classes(variant: :unknown)

      expect(result).to include('bg-blue-600')
      expect(result).to include('text-white')
    end

    it 'combines variant and full_width correctly' do
      result = instance.button_classes(variant: :secondary, full_width: true)

      expect(result).to include('border border-slate-300')
      expect(result).to include('w-full')
    end

    it 'does not have extra whitespace' do
      result = instance.button_classes

      expect(result).not_to start_with(' ')
      expect(result).not_to end_with(' ')
      expect(result).not_to include('  ')
    end
  end
end
