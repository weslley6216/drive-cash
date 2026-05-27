require 'rails_helper'

RSpec.describe TodayCardComponent, type: :component do
  let(:component) do
    TodayCardComponent.new(
      earnings: 150.0,
      expenses: 40.0,
      net: 110.0,
      trips_count: 5,
      duration_label: '3h20'
    )
  end
  let(:html) { view_context.render(component) }

  it 'renders the "Hoje" label' do
    expect(html).to include(I18n.t('today_card_component.label'))
  end

  it 'renders net value formatted as currency' do
    expect(html).to include('110,00')
  end

  it 'renders earnings with positive sign in emerald' do
    expect(html).to include('+')
    expect(html).to include('150,00')
    expect(html).to include('text-emerald-600')
  end

  it 'renders expenses with minus sign in red' do
    expect(html).to include('40,00')
    expect(html).to include('text-red-600')
  end

  it 'renders trips count and duration label' do
    expect(html).to include('5 corridas')
    expect(html).to include('3h20')
  end

  context 'when trips_count is zero and no duration' do
    let(:component) do
      TodayCardComponent.new(earnings: 50.0, expenses: 10.0, net: 40.0, trips_count: 0)
    end

    it 'does not render detail text' do
      expect(html).not_to include('corrida')
    end
  end

  context 'with single trip' do
    let(:component) do
      TodayCardComponent.new(earnings: 30.0, expenses: 5.0, net: 25.0, trips_count: 1)
    end

    it 'uses singular form' do
      expect(html).to include('1 corrida')
      expect(html).not_to include('corridas')
    end
  end
end
