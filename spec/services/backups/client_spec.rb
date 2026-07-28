require 'rails_helper'

RSpec.describe Backups::Client do
  let(:config) { instance_double(Backups::Config, service_account_json: '{"type":"service_account"}') }
  let(:authorizer) { instance_double(Google::Auth::ServiceAccountCredentials) }

  before { allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(authorizer) }

  describe '.build' do
    it 'returns a sheets service authorized with the service account' do
      service = described_class.build(config: config)

      expect(service).to be_a(Google::Apis::SheetsV4::SheetsService)
      expect(service.authorization).to eq(authorizer)
    end

    it 'builds the credentials from the configured json and the spreadsheets scope' do
      described_class.build(config: config)

      expect(Google::Auth::ServiceAccountCredentials).to have_received(:make_creds) do |args|
        expect(args[:json_key_io].read).to eq('{"type":"service_account"}')
        expect(args[:scope]).to eq(described_class::SCOPE)
      end
    end

    it 'identifies the client to the sheets api' do
      service = described_class.build(config: config)

      expect(service.client_options.application_name).to eq('DriveCash Backup')
    end

    it 'propagates a configuration error when the json is missing' do
      allow(config).to receive(:service_account_json).and_raise(Backups::ConfigurationError, 'GOOGLE_BACKUP_SA_JSON is not set.')

      expect { described_class.build(config: config) }.to raise_error(Backups::ConfigurationError)
    end
  end
end
