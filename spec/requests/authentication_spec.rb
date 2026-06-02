require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'unauthenticated access' do
    it 'redirects root to login' do
      get root_path

      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects history to login' do
      get history_path

      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects analysis to login' do
      get analysis_path

      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects new record to login' do
      get new_record_path

      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects chat root to login' do
      get chat_root_path

      expect(response).to redirect_to(new_session_path)
    end
  end
end
