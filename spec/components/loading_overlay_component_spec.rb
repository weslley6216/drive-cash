require 'rails_helper'

RSpec.describe LoadingOverlayComponent, type: :component do
  let(:html) { view_context.render(described_class.new) }

  it 'mounts the generic loading controller on a permanent overlay' do
    expect(html).to include('id="loading-overlay"')
    expect(html).to include('data-controller="loading"')
    expect(html).to include('data-turbo-permanent')
  end

  it 'stacks a spinner and a message slot in one column' do
    expect(html).to include('flex flex-col items-center gap-3')
    expect(html).to include('animate-spin')
  end

  it 'renders the message slot empty and hidden until something holds the screen' do
    expect(html).to include('data-loading-target="message"></p>')
    expect(html).to match(/<p class="hidden /)
  end
end
