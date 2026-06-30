require 'rails_helper'

RSpec.describe ExportJob do
  describe '#perform' do
    it 'builds the report, attaches the file, and marks the export as done' do
      export = create(:export, format: 'csv')
      create(:earning, user: export.user, date: Date.new(2026, 6, 15))

      described_class.perform_now(export.id)

      export.reload
      expect(export).to be_status_done
      expect(export.file).to be_attached
    end

    it 'marks the export as failed and re-raises when generation fails' do
      export = create(:export)
      allow(Exports::Builder).to receive(:call).and_raise(StandardError, 'boom')

      expect { described_class.perform_now(export.id) }.to raise_error(StandardError, 'boom')
      expect(export.reload).to be_status_failed
    end
  end
end
