require 'rails_helper'

RSpec.describe BackupsMailer, type: :mailer do
  around do |example|
    original = ENV.to_hash
    example.run
    ENV.replace(original)
  end

  before { ENV['BACKUP_TARGET_EMAIL'] = 'owner@gmail.com' }

  describe '#failure' do
    it 'sends to the backup target address with the i18n subject' do
      mail = described_class.failure('Backups::ConfigurationError', 'GOOGLE_BACKUP_SA_JSON is not set.')

      expect(mail.to).to eq(['owner@gmail.com'])
      expect(mail.subject).to eq(I18n.t('backups.mailer.failure.subject'))
    end

    it 'renders the error class and message in the body' do
      mail = described_class.failure('Backups::ConfigurationError', 'GOOGLE_BACKUP_SA_JSON is not set.')

      expect(mail.body.encoded).to include('Backups::ConfigurationError')
      expect(mail.body.encoded).to include('GOOGLE_BACKUP_SA_JSON is not set.')
    end
  end
end
