require 'rails_helper'

RSpec.describe ExportJob do
  describe '#perform' do
    before { ActiveJob::Base.queue_adapter.enqueued_jobs.clear }

    it 'builds the report, attaches the file, and marks the export as done' do
      export = create(:export, format: 'csv')
      create(:earning, user: export.user, date: Date.new(2026, 6, 15))

      described_class.perform_now(export.id)

      export.reload
      expect(export).to be_status_done
      expect(export.file).to be_attached
    end

    it 'keeps the export processing and enqueues a retry when an attempt fails' do
      export = create(:export)
      allow(Exports::Builder).to receive(:call).and_raise(StandardError, 'boom')

      described_class.perform_now(export.id)

      expect(export.reload).to be_status_processing
      expect(described_class).to have_been_enqueued.exactly(:once)
    end

    it 'marks the export as failed and re-raises once the attempts run out' do
      export = create(:export)
      allow(Exports::Builder).to receive(:call).and_raise(StandardError, 'boom')
      job = described_class.new(export.id)
      job.exception_executions = { '[StandardError]' => described_class::MAX_ATTEMPTS }

      expect { job.perform_now }.to raise_error(StandardError, 'boom')
      expect(export.reload).to be_status_failed
    end

    it 'discards the job without retrying when the export no longer exists' do
      described_class.perform_now(0)

      expect(described_class).not_to have_been_enqueued
    end
  end
end
