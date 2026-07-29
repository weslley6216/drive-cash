require 'rails_helper'

RSpec.describe Exports::StaleMarker do
  let(:user) { create(:user) }

  it 'fails an export left processing beyond the stale window' do
    export = create(:export, user: user, status: 'processing')
    export.update_column(:updated_at, (Export::STALE_AFTER + 1.minute).ago)

    described_class.call(export: export)

    expect(export.reload).to be_status_failed
  end

  it 'keeps an export that is still within the stale window' do
    export = create(:export, user: user, status: 'processing')

    described_class.call(export: export)

    expect(export.reload).to be_status_processing
  end

  it 'keeps a finished export untouched' do
    export = create(:export, user: user, status: 'done')
    export.update_column(:updated_at, (Export::STALE_AFTER + 1.minute).ago)

    described_class.call(export: export)

    expect(export.reload).to be_status_done
  end

  it 'returns the export so callers can render it' do
    export = create(:export, user: user, status: 'pending')

    expect(described_class.call(export: export)).to eq(export)
  end
end
