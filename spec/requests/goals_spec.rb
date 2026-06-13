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

    it 'renders the money placeholder from the form_fields fallback' do
      get new_goal_path

      expect(response.body).to include('placeholder="R$ 0,00"')
      expect(response.body).not_to include('translation missing')
    end

    it 'renders kind and metric selects without a blank option and with defaults selected' do
      get new_goal_path

      expect(response.body).not_to include('<option value="" label=" "></option>')
      expect(response.body).to include('selected="selected" value="monthly"')
      expect(response.body).to include('selected="selected" value="profit"')
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

    it 'creates a goal and responds with modal clear and turbo_stream refresh' do
      post goals_path, params: valid_params, as: :turbo_stream

      expect(Goal.count).to eq(1)
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include('action="update"').and include('action="refresh"')
    end

    it 'still redirects to /goals for non-turbo (html) submissions' do
      post goals_path, params: valid_params

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

    it 'updates the goal and responds with modal clear and turbo_stream refresh' do
      patch goal_path(goal), params: { goal: { target_amount: '9000.00' } }, as: :turbo_stream

      expect(goal.reload.target_amount).to eq(9000)
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include('action="update"').and include('action="refresh"')
    end

    it 'still redirects to /goals for non-turbo (html) updates' do
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
