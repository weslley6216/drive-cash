require 'rails_helper'

RSpec.describe Exports::Requeuer do
  let(:user) { create(:user) }

  it 'sends a failed export back to the queue' do
    export = create(:export, user: user, status: 'failed')

    described_class.call(export: export)

    expect(export.reload).to be_status_pending
  end

  it 'enqueues the job again' do
    export = create(:export, user: user, status: 'failed')

    expect { described_class.call(export: export) }.to have_enqueued_job(ExportJob).with(export.id)
  end

  it 'preserves period, format and includes' do
    export = create(:export, user: user, status: 'failed', period_kind: 'custom',
                             period_start: Date.new(2026, 2, 1), period_end: Date.new(2026, 2, 28), format: 'csv')

    described_class.call(export: export)

    expect(export.reload.period_start).to eq(Date.new(2026, 2, 1))
    expect(export.period_end).to eq(Date.new(2026, 2, 28))
    expect(export.format).to eq('csv')
    expect(export.includes_for(:earnings)).to be true
  end

  it 'leaves a finished export untouched' do
    export = create(:export, user: user, status: 'done')

    expect { described_class.call(export: export) }.not_to have_enqueued_job(ExportJob)
    expect(export.reload).to be_status_done
  end

  it 'returns the export so callers can render it' do
    export = create(:export, user: user, status: 'failed')

    expect(described_class.call(export: export)).to eq(export)
  end
end
