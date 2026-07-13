require 'rails_helper'

RSpec.describe AvatarComponent, type: :component do
  it 'renders the uppercased first letter of the name inside a blue circle with the given size' do
    html = view_context.render(described_class.new(name: 'weslley campos', size_classes: 'w-14 h-14 text-xl'))

    expect(html).to include('w-14 h-14 text-xl rounded-full bg-blue-600')
    expect(html).to match(/>\s*W\s*</)
  end

  it 'falls back to a question mark when the name is blank' do
    html = view_context.render(described_class.new(name: '   ', size_classes: 'w-16 h-16'))

    expect(html).to match(/>\s*\?\s*</)
  end
end
