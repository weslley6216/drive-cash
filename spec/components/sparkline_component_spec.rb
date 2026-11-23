require 'rails_helper'

RSpec.describe SparklineComponent, type: :component do
  let(:sparkline) { { values: [10.0, 20.0, 15.0], color: '#2563eb', height: 20, height_class: 'h-5', fill: true } }

  it 'renders a full-width svg scaled by viewBox' do
    expect(view_context.render(described_class.new(**sparkline))).to include('w-full')
    expect(view_context.render(described_class.new(**sparkline))).to include('viewBox="0 0 100 20"')
  end

  it 'plots the line from the first to the last value' do
    result = view_context.render(described_class.new(**sparkline, values: [0, 10, 5], height: 20))

    expect(result).to include('d="M0.0,18.0 L50.0,2.0 L100.0,10.0"')
  end

  it 'renders the filled area when fill is true' do
    result = view_context.render(described_class.new(**sparkline, fill: true))

    expect(result.scan('<path').size).to eq(2)
    expect(result).to include('fill-opacity="0.12"')
  end

  it 'renders only the line when fill is false' do
    result = view_context.render(described_class.new(**sparkline, fill: false))

    expect(result.scan('<path').size).to eq(1)
  end

  it 'uses the given color' do
    result = view_context.render(described_class.new(**sparkline, color: '#94a3b8'))

    expect(result).to include('#94a3b8')
  end
end
