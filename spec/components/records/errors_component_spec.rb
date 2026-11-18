require 'rails_helper'

RSpec.describe Records::ErrorsComponent, type: :component do
  it 'lists the record errors in a red box' do
    earning = Earning.new
    earning.errors.add(:amount, :greater_than, count: 0)

    html = view_context.render(described_class.new(record: earning))

    expect(html).to include('bg-red-50')
    expect(html).to include(earning.errors.full_messages.to_sentence)
  end

  it 'renders nothing when the record has no errors' do
    html = view_context.render(described_class.new(record: Earning.new))

    expect(html).to eq('')
  end
end
