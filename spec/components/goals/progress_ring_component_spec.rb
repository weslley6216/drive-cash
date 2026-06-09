require 'rails_helper'

RSpec.describe Goals::ProgressRingComponent, type: :component do
  let(:html) { view_context.render(described_class.new(**props)) }

  context 'with default size' do
    let(:props) { { percent: 60 } }

    it 'renders an svg with default 120px size' do
      expect(html).to include('width="120" height="120"')
    end

    it 'shows the percent value as label' do
      expect(html).to include('60</span>')
    end
  end

  context 'with custom size and color' do
    let(:props) { { percent: 75, size: 220, color: '#10b981', stroke: 16 } }

    it 'renders an svg with 220px size for hero variant' do
      expect(html).to include('width="220" height="220"')
    end

    it 'uses the provided stroke color on the progress circle' do
      expect(html).to include('stroke="#10b981"')
    end
  end

  context 'edge cases for percent' do
    it 'clamps percent above 100 to 100' do
      output = view_context.render(described_class.new(percent: 150))

      expect(output).to include('100</span>')
    end

    it 'clamps percent below 0 to 0' do
      output = view_context.render(described_class.new(percent: -5))

      expect(output).to include('0</span>')
    end

    it 'accepts string-like numeric input' do
      output = view_context.render(described_class.new(percent: '42'))

      expect(output).to include('42</span>')
    end
  end

  context 'stroke-dashoffset' do
    it 'computes dashoffset proportional to percent' do
      output = view_context.render(described_class.new(percent: 50, size: 120, stroke: 10))

      circumference = (2 * Math::PI * ((120 - 10) / 2.0)).round(4)
      offset = (circumference - circumference * 0.5).round(4)
      expect(output).to include("stroke-dashoffset=\"#{offset}\"")
    end
  end
end
