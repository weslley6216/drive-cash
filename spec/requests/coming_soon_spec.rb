require 'rails_helper'

RSpec.describe 'Coming soon placeholders', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  %w[/work_session /settings].each do |path|
    describe "GET #{path}" do
      it 'responds 200 with em breve content' do
        get path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t('application.coming_soon_view.title'))
        expect(response.body).to include(I18n.t('application.coming_soon_view.back'))
        expect(response.body).to include('href="/"')
      end

      it 'renders bottom nav so users can navigate away' do
        get path

        expect(response.body).to include('fixed bottom-0 left-0 right-0')
        expect(response.body).to include(I18n.t('bottom_nav_component.tabs.home'))
      end
    end
  end
end
