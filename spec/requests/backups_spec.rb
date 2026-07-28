require 'rails_helper'

RSpec.describe 'Backups', type: :request do
  let(:token) { 'a-very-strong-token' }

  around do |example|
    original = ENV.to_hash
    example.run
    ENV.replace(original)
  end

  before do
    ENV['BACKUP_TRIGGER_TOKEN'] = token
    allow(Backups::SheetSync).to receive(:call)
  end

  describe 'POST /backups' do
    it 'runs the sync and returns ok with a valid bearer token' do
      post backups_path, headers: { 'Authorization' => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      expect(Backups::SheetSync).to have_received(:call)
    end

    it 'returns unauthorized without an authorization header' do
      post backups_path

      expect(response).to have_http_status(:unauthorized)
      expect(Backups::SheetSync).not_to have_received(:call)
    end

    it 'returns unauthorized with a wrong token' do
      post backups_path, headers: { 'Authorization' => 'Bearer wrong-token' }

      expect(response).to have_http_status(:unauthorized)
      expect(Backups::SheetSync).not_to have_received(:call)
    end

    it 'returns unauthorized when the token is sent without the bearer scheme' do
      post backups_path, headers: { 'Authorization' => token }

      expect(response).to have_http_status(:unauthorized)
      expect(Backups::SheetSync).not_to have_received(:call)
    end

    it 'returns unauthorized when the server has no token configured' do
      ENV.delete('BACKUP_TRIGGER_TOKEN')

      post backups_path, headers: { 'Authorization' => 'Bearer anything' }

      expect(response).to have_http_status(:unauthorized)
      expect(Backups::SheetSync).not_to have_received(:call)
    end

    it 'returns internal server error when the sync fails' do
      allow(Backups::SheetSync).to receive(:call).and_raise(Backups::ConfigurationError, 'GOOGLE_BACKUP_SA_JSON is not set.')

      post backups_path, headers: { 'Authorization' => "Bearer #{token}" }

      expect(response).to have_http_status(:internal_server_error)
    end

    it 'logs the failure cause' do
      allow(Backups::SheetSync).to receive(:call).and_raise(Backups::SheetSync::MissingUser, 'no user with email x@y.com')
      allow(Rails.logger).to receive(:error)

      post backups_path, headers: { 'Authorization' => "Bearer #{token}" }

      expect(Rails.logger).to have_received(:error).with(/MissingUser.*no user with email x@y.com/)
    end

    it 'does not require an authenticated session' do
      post backups_path, headers: { 'Authorization' => "Bearer #{token}" }

      expect(response).not_to redirect_to(new_session_path)
    end
  end
end
