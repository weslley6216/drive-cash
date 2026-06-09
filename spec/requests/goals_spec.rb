require 'rails_helper'

RSpec.describe 'Goals', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /goals' do
    it 'renders successfully' do
      get goals_path

      expect(response).to have_http_status(:success)
    end

    it 'highlights goals tab in bottom nav' do
      get goals_path

      expect(response.body).to include('href="/goals"')
      expect(response.body).to include('text-blue-600')
    end

    it 'renders empty CTA when user has no goals' do
      get goals_path

      expect(response.body).to include(I18n.t('goals.index.empty.title'))
      expect(response.body).to include(I18n.t('goals.index.empty.cta'))
    end

    it 'renders monthly hero when a monthly goal exists' do
      create(:goal,
             user: current_user,
             kind: 'monthly',
             target_amount: 6000,
             period_start: Date.current.beginning_of_month,
             period_end: Date.current.end_of_month)
      create(:earning, user: current_user, date: Date.current, amount: 1500)

      get goals_path

      expect(response.body).to include(I18n.t('goals.index.monthly.label'))
      expect(response.body).to include('R$ 1.500,00')
    end
  end

  describe 'GET /goals/new' do
    it 'renders the modal form' do
      get new_goal_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame')
      expect(response.body).to include(I18n.t('goals.index.form.title_new'))
    end
  end

  describe 'POST /goals' do
    let(:valid_params) do
      {
        goal: {
          kind: 'monthly',
          target_amount: '6000.00',
          period_start: Date.current.beginning_of_month.to_s,
          period_end: Date.current.end_of_month.to_s,
          metric: 'profit'
        }
      }
    end

    it 'creates a goal and redirects to /goals' do
      expect {
        post goals_path, params: valid_params
      }.to change(Goal, :count).by(1)

      expect(response).to redirect_to(goals_path)
    end

    it 'rerenders the form with errors on invalid params' do
      post goals_path, params: { goal: { kind: 'monthly', target_amount: '0' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('goals.index.form.title_new'))
    end
  end

  describe 'GET /goals/:id/edit' do
    let(:goal) do
      create(:goal,
             user: current_user,
             kind: 'monthly',
             target_amount: 5000,
             period_start: Date.current.beginning_of_month,
             period_end: Date.current.end_of_month)
    end

    it 'renders the edit modal form' do
      get edit_goal_path(goal)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('goals.index.form.title_edit'))
    end
  end

  describe 'PATCH /goals/:id' do
    let(:goal) do
      create(:goal,
             user: current_user,
             kind: 'monthly',
             target_amount: 5000,
             period_start: Date.current.beginning_of_month,
             period_end: Date.current.end_of_month)
    end

    it 'updates the goal' do
      patch goal_path(goal), params: { goal: { target_amount: '9000.00' } }

      expect(goal.reload.target_amount).to eq(9000)
      expect(response).to redirect_to(goals_path)
    end

    it 'rerenders the edit form with errors on invalid params' do
      patch goal_path(goal), params: { goal: { target_amount: '0' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('goals.index.form.title_edit'))
    end
  end

  describe 'DELETE /goals/:id' do
    let(:goal) do
      create(:goal,
             user: current_user,
             kind: 'monthly',
             target_amount: 5000,
             period_start: Date.current.beginning_of_month,
             period_end: Date.current.end_of_month)
    end

    before { goal }

    it 'destroys the goal and redirects' do
      expect {
        delete goal_path(goal)
      }.to change(Goal, :count).by(-1)

      expect(response).to redirect_to(goals_path)
    end

    it 'scopes find to current user (404 for other users goals)' do
      other_user = create(:user)
      other_goal = create(:goal, user: other_user,
                                 kind: 'weekly',
                                 period_start: Date.current.beginning_of_week,
                                 period_end: Date.current.end_of_week)

      delete goal_path(other_goal)

      expect(response).to have_http_status(:not_found)
    end
  end
end
