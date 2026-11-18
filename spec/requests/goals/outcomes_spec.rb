require 'rails_helper'

RSpec.describe 'Goals::Outcomes', type: :request do
  let(:user) { create(:user) }
  let(:goal) do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                  period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
  end

  before { travel_to Time.zone.local(2026, 7, 2, 10, 0) }

  describe 'GET /goals/:goal_id/outcomes/:period_start' do
    it 'redirects to login when unauthenticated' do
      get goal_outcome_path(goal, '2026-06-01')

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'renders the hit outcome and stamps the first celebration with the confetti' do
        create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 1_200)

        get goal_outcome_path(goal, '2026-06-01')

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Meta de junho batida!')
        expect(response.body).to include('dc-confetti')
        expect(goal.reload.celebrated_at).to eq(Time.zone.local(2026, 7, 2, 10, 0))
      end

      it 'renders a later visit without the confetti' do
        create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 1_200)
        goal.update!(celebrated_at: Time.zone.local(2026, 7, 1, 8, 0))

        get goal_outcome_path(goal, '2026-06-01')

        expect(response.body).to include('Meta de junho batida!')
        expect(response.body).not_to include('dc-confetti')
      end

      it 'leaves the celebration for the real visit when Turbo prefetches the link' do
        create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 1_200)

        get goal_outcome_path(goal, '2026-06-01'), headers: { 'X-Sec-Purpose' => 'prefetch' }

        expect(response.body).to include('Meta de junho batida!')
        expect(response.body).not_to include('dc-confetti')
        expect(goal.reload.celebrated_at).to be_nil
      end

      it 'redirects to the goals list while the open period is short of the target' do
        open_goal = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                                  period_start: Date.new(2026, 7, 1), period_end: Date.new(2026, 7, 31))
        create(:earning, user: user, date: Date.new(2026, 7, 1), amount: 400)

        get goal_outcome_path(open_goal, '2026-07-01')

        expect(response).to redirect_to(goals_path)
        expect(open_goal.reload.celebrated_at).to be_nil
      end

      it 'responds not found for a period start that is not the goal period' do
        get goal_outcome_path(goal, '2026-05-01')

        expect(response).to have_http_status(:not_found)
      end

      it 'responds not found for the goal of another user' do
        other_goal = create(:goal, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                                   period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
        create(:earning, user: other_goal.user, date: Date.new(2026, 6, 10), amount: 1_200)

        get goal_outcome_path(other_goal, '2026-06-01')

        expect(response).to have_http_status(:not_found)
        expect(other_goal.reload.celebrated_at).to be_nil
      end
    end
  end
end
