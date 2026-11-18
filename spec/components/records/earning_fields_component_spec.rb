require 'rails_helper'

RSpec.describe Records::EarningFieldsComponent, type: :component do
  let(:earning) { build(:earning, platform: 'uber', trips_count: 3, notes: 'Bônus de domingo') }
  let(:html) { view_context.render(described_class.new(earning: earning)) }

  it 'checks the earning platform' do
    expect(html).to include('value="uber" checked')
  end

  it 'starts the trips stepper at the earning trips' do
    expect(html).to include('name="record[trips_count]" value="3"')
  end

  it 'fills the notes with the earning notes' do
    expect(html).to include('Bônus de domingo')
  end

  it 'starts the trips stepper at one when the earning has no trips' do
    html = view_context.render(described_class.new(earning: Earning.new))

    expect(html).to include('name="record[trips_count]" value="1"')
  end
end
