require 'rails_helper'

RSpec.describe 'Backups', type: :request do
  let(:token) { 'a-very-strong-token' }

  around do |example|
    original = ENV.to_hash
    example.run
    ENV.replace(original)
  end

  before { ENV['BACKUP_TRIGGER_TOKEN'] = token }

  describe 'POST /backups' do
    it 'enqueues the backup and returns accepted with a valid bearer token' do
      expect {
        post backups_path, headers: { 'Authorization' => "Bearer #{token}" }
      }.to have_enqueued_job(BackupJob)

      expect(response).to have_http_status(:accepted)
    end

    it 'returns unauthorized without an authorization header' do
      expect { post backups_path }.not_to have_enqueued_job(BackupJob)

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized with a wrong token' do
      expect {
        post backups_path, headers: { 'Authorization' => 'Bearer wrong-token' }
      }.not_to have_enqueued_job(BackupJob)

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized when the token is sent without the bearer scheme' do
      expect {
        post backups_path, headers: { 'Authorization' => token }
      }.not_to have_enqueued_job(BackupJob)

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized when the server has no token configured' do
      ENV.delete('BACKUP_TRIGGER_TOKEN')

      expect {
        post backups_path, headers: { 'Authorization' => 'Bearer anything' }
      }.not_to have_enqueued_job(BackupJob)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
