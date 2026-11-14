require 'rails_helper'

RSpec.describe Auth::BackToLoginComponent, type: :component do
  let(:html) { view_context.render(described_class.new) }

  it 'links back to the sign in screen with a 44px touch target on the phone' do
    expect(html).to include('href="/session/new"')
    expect(html).to include('h-11 -ml-1')
    expect(html).to include(I18n.t('auth.back_to_login_component.label'))
  end
end
