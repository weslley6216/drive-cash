require 'rails_helper'

RSpec.describe 'Help', type: :request do
  let(:user) { create(:user) }

  describe 'GET /help' do
    it 'redirects to login when unauthenticated' do
      get help_path

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'renders the help heading and sections' do
        get help_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('help.show_view.heading'))
        expect(response.body).to include(I18n.t('help.show_view.faq_title'))
        expect(response.body).to include(I18n.t('help.show_view.contact_title'))
        expect(response.body).to include(I18n.t('help.show_view.about_title'))
      end

      it 'renders every FAQ question wired as an independent disclosure' do
        get help_path

        questions = I18n.t('help.show_view.faqs').map { |faq| faq[:question] }
        questions.each { |question| expect(response.body).to include(question) }
        expect(response.body.scan('data-controller="disclosure"').size).to eq(questions.size)
      end

      it 'links email to mailto and placeholders to coming_soon' do
        get help_path

        expect(response.body).to include('href="mailto:ajuda@drivecash.app"')
        expect(response.body).to include('href="/coming_soon"')
      end

      it 'links the back button to the account hub' do
        get help_path

        expect(response.body).to include('href="/account"')
      end
    end
  end
end
