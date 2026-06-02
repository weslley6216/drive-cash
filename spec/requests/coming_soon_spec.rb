require 'rails_helper'

RSpec.describe 'Coming soon placeholders', type: :request do
  %w[/work_session /settings].each do |path|
    describe "GET #{path}" do
      it 'responds 200 with em breve content' do
        get path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t('application.coming_soon_view.title'))
        expect(response.body).to include(I18n.t('application.coming_soon_view.back'))
        expect(response.body).to include('href="/"')
      end
    end
  end
end
