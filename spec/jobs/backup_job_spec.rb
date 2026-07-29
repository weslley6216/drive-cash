require 'rails_helper'

RSpec.describe BackupJob do
  describe '#perform' do
    it 'runs the spreadsheet sync' do
      allow(Backups::SheetSync).to receive(:call)

      described_class.perform_now

      expect(Backups::SheetSync).to have_received(:call)
    end

    it 're-raises when the sync fails' do
      allow(Backups::SheetSync).to receive(:call).and_raise(Backups::SheetSync::MissingUser, 'no user with email x@y.com')

      expect { described_class.perform_now }.to raise_error(Backups::SheetSync::MissingUser)
    end

    it 'logs the failure cause' do
      allow(Backups::SheetSync).to receive(:call).and_raise(Backups::SheetSync::MissingUser, 'no user with email x@y.com')
      allow(Rails.logger).to receive(:error)

      expect { described_class.perform_now }.to raise_error(Backups::SheetSync::MissingUser)

      expect(Rails.logger).to have_received(:error).with(/no user with email x@y.com \(Backups::SheetSync::MissingUser\)/)
    end

    it 'enqueues the failure email with the error cause' do
      allow(Backups::SheetSync).to receive(:call).and_raise(Backups::SheetSync::MissingUser, 'no user with email x@y.com')

      expect {
        expect { described_class.perform_now }.to raise_error(Backups::SheetSync::MissingUser)
      }.to have_enqueued_mail(BackupsMailer, :failure).with('Backups::SheetSync::MissingUser', 'no user with email x@y.com')
    end

    it 'does not enqueue the failure email when the sync succeeds' do
      allow(Backups::SheetSync).to receive(:call)

      expect { described_class.perform_now }.not_to have_enqueued_mail(BackupsMailer, :failure)
    end

    it 'logs where the failure came from' do
      allow(Backups::SheetSync).to receive(:call).and_raise(Backups::ConfigurationError, 'GOOGLE_BACKUP_SA_JSON is not set.')
      allow(Rails.logger).to receive(:error)

      expect { described_class.perform_now }.to raise_error(Backups::ConfigurationError)

      expect(Rails.logger).to have_received(:error).with(/backup_job\.rb/)
    end
  end
end
