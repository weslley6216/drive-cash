require 'rails_helper'

RSpec.describe Records::TripsStepperComponent, type: :component do
  let(:html) { view_context.render(described_class.new(value: 7)) }

  it 'renders the current value' do
    expect(html).to include('data-record-form-target="tripsValue"')
    expect(html).to include('>7<')
  end

  it 'renders + and − buttons with Stimulus actions' do
    expect(html).to include('data-action="click->record-form#decrementTrips"')
    expect(html).to include('data-action="click->record-form#incrementTrips"')
  end

  it 'renders the hidden trips_count input' do
    expect(html).to include('name="record[trips_count]"')
    expect(html).to include('value="7"')
  end

  it 'renders the label' do
    expect(html).to include(I18n.t('records.new_view.trips_count'))
  end
end
