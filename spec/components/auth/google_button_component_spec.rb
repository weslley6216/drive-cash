require 'rails_helper'

RSpec.describe Auth::GoogleButtonComponent, type: :component do
  it 'posts to the Google OAuth endpoint with the neutral G badge' do
    html = view_context.render(described_class.new)

    expect(html).to include('action="/auth/google_oauth2"')
    expect(html).to include('name="authenticity_token"')
    expect(html).to include('from-blue-500 via-emerald-500 to-amber-500')
    expect(html).to include(I18n.t('auth.google_button_component.label'))
  end
end
