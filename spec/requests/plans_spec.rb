require 'rails_helper'

RSpec.describe 'Plans', type: :request do
  let(:user) { create(:user) }

  describe 'GET /plan' do
    it 'redirects to login when unauthenticated' do
      get plan_path

      expect(response).to redirect_to(new_session_path)
    end

    context 'when the user is free' do
      before { login_as(user) }

      it 'renders the sales screen comparing both plans' do
        get plan_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('plans.show_view.heading'))
        expect(response.body).to include(I18n.t('plans.show_view.current_plan'))
        expect(response.body).to include(I18n.t('plans.free_card.forever'))
        expect(response.body).to include(I18n.t('plans.pro_card.recommended'))
      end

      it 'renders both billing prices so the toggle works client-side' do
        get plan_path

        expect(response.body).to include('R$ 11,92')
        expect(response.body).to include('R$ 14,90')
        expect(response.body).to include('data-controller="plan-billing"')
      end

      it 'advertises the yearly discount derived from the catalog' do
        get plan_path

        expect(response.body).to include('−20%')
      end

      it 'links the back button to the account hub' do
        get plan_path

        expect(response.body).to include('href="/account"')
      end

      it 'renders the desktop pitch alongside the mobile layout' do
        get plan_path

        expect(response.body).to include(I18n.t('plans.show_view.desktop_headline'))
        expect(response.body).to include(I18n.t('plans.show_view.mobile_subtitle'))
      end
    end
  end

  describe 'PATCH /plan' do
    before { login_as(user) }

    it 'answers the subscribe cta with an honest checkout notice' do
      patch plan_path

      expect(response).to redirect_to(plan_path)
      follow_redirect!
      expect(response.body).to include(I18n.t('plans.flash.checkout_soon'))
    end

    it 'does not upgrade the user without a real payment' do
      patch plan_path

      expect(user.reload).to be_free
    end
  end
end
