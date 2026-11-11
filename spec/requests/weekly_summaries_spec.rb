require 'rails_helper'

RSpec.describe 'WeeklySummaries', type: :request do
  let(:user) { create(:user) }

  describe 'GET /weekly_summaries/:week_start' do
    it 'redirects to login when unauthenticated' do
      get weekly_summary_path('2026-07-06')

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'renders the week of the current user' do
        create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 987.40, trips_count: 10)
        create(:earning, date: Date.new(2026, 7, 6), amount: 5_000, trips_count: 1)

        get weekly_summary_path('2026-07-06')

        expect(response.body).to include('Sua semana')
        expect(response.body).to include('6 a 12 de julho')
        expect(response.body).to include('R$ 987,40')
        expect(response.body).not_to include('R$ 5.987,40')
      end

      it 'responds not found for a malformed week start' do
        get weekly_summary_path('abc')

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
