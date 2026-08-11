require 'rails_helper'

RSpec.describe Exports::Requeuer do
  let(:user) { create(:user) }

  it 'sends a failed export back to the queue and enqueues the job again' do
    export = create(:export, user: user, status: 'failed')

    expect { described_class.call(export: export) }.to have_enqueued_job(ExportJob).with(export.id)

    expect(export.reload).to be_status_pending
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

  it 'keeps the original period of a relative kind retried in a later year' do
    export = travel_to(Time.zone.local(2026, 12, 31, 23, 0, 0)) do
      create(:export, user: user, status: 'failed', period_kind: 'year', period_start: nil, period_end: nil)
    end

    travel_to(Time.zone.local(2027, 1, 2, 10, 0, 0)) { described_class.call(export: export) }

    expect(export.reload.period_start).to eq(Date.new(2026, 1, 1))
    expect(export.period_end).to eq(Date.new(2026, 12, 31))
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
