require 'rails_helper'

RSpec.describe Backups::Snapshot do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }

  describe '.call' do
    it 'mirrors earnings in chronological order with a translated platform' do
      create(:earning, user: user, date: Date.new(2026, 3, 5), amount: 200.00, platform: 'uber', trips_count: 4, notes: 'sábado')
      create(:earning, user: user, date: Date.new(2026, 1, 2), amount: 50.00, platform: 'ifood', trips_count: 1)

      rows = described_class.call(user: user).rows[:earnings]

      expect(rows.map(&:first)).to eq(['2026-01-02', '2026-03-05'])
      expect(rows.last[1]).to eq('Uber')
      expect(rows.last[2]).to eq(200.0)
      expect(rows.last[3]).to eq(4)
      expect(rows.last[4]).to eq('sábado')
    end

    it 'stamps the earning creation time in the brasilia zone' do
      travel_to Time.zone.local(2026, 3, 5, 21, 30) do
        create(:earning, user: user, date: Date.new(2026, 3, 5))
      end

      rows = described_class.call(user: user).rows[:earnings]

      expect(rows.first.last).to eq('2026-03-05 21:30:00')
    end

    it 'mirrors expenses with translated category, paid label and installment columns' do
      create(:expense, user: user, date: Date.new(2026, 2, 10), amount: 50.00, category: 'fuel',
                       vendor: 'Posto Orense', description: 'gasolina', paid: false,
                       installment_number: 2, installment_count: 3)

      row = described_class.call(user: user).rows[:expenses].first

      expect(row).to eq(['2026-02-10', 'Combustível', 50.0, 'Posto Orense', 'gasolina', 'Não', 2, 3])
    end

    it 'mirrors refuelings of the user vehicle' do
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 4, 1), vendor: 'Shell',
                         liters: 32.5, total_amount: 191.72,
                         odometer_km: 48_230, full_tank: true)

      row = described_class.call(user: user).rows[:refuelings].first

      expect(row).to eq(['2026-04-01', 'Shell', 32.5, 5.899, 191.72, 48_230, 'Sim'])
    end

    it 'mirrors the vehicle maintenance plan with a translated item' do
      create(:maintenance, vehicle: vehicle, category: 'oil_change', interval_km: 5_000,
                           last_done_km: 158_318, estimated_cost: 280.00)

      row = described_class.call(user: user).rows[:maintenances].first

      expect(row).to eq(['Troca de óleo', 5_000, 158_318, 280.0])
    end

    it 'mirrors goals with translated kind and metric' do
      create(:goal, user: user, kind: 'monthly', metric: 'profit',
                    period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31),
                    target_amount: 7_000.00)

      row = described_class.call(user: user).rows[:goals].first

      expect(row).to eq(['Mensal', 'Lucro', '2026-05-01', '2026-05-31', 7_000.0])
    end

    it 'builds every row with the width its tab declares' do
      create(:earning, user: user)
      create(:expense, user: user)
      create(:refueling, vehicle: vehicle)
      create(:maintenance, vehicle: vehicle)
      create(:goal, user: user)

      widths = described_class.call(user: user).rows.transform_values { |rows| rows.map(&:size).uniq }

      expect(widths).to eq(widths.keys.index_with { |key| [Backups::Tabs.find(key).width] })
    end

    it 'produces a row set for every mirrored tab of the registry' do
      expect(described_class.call(user: user).rows.keys)
        .to match_array(Backups::Tabs::ALL.map(&:key) - [:summary])
    end

    it 'leaves nullable numeric columns empty instead of zeroing them' do
      create(:refueling, vehicle: vehicle, liters: nil, total_amount: 191.72)
      create(:maintenance, vehicle: vehicle, estimated_cost: nil)

      payload = described_class.call(user: user)

      expect(payload.rows[:refuelings].first[2..3]).to eq([nil, nil])
      expect(payload.rows[:maintenances].first.last).to be_nil
    end

    it 'ignores records that belong to another user' do
      create(:earning, user: create(:user), amount: 999.00)

      expect(described_class.call(user: user).rows[:earnings]).to be_empty
    end

    context 'when the user has no vehicle' do
      it 'returns empty vehicle-scoped tabs without raising' do
        payload = described_class.call(user: user)

        expect(payload.rows[:refuelings]).to eq([])
        expect(payload.rows[:maintenances]).to eq([])
      end

      it 'still mirrors the user own records' do
        create(:earning, user: user, amount: 100.00)

        expect(described_class.call(user: user).rows[:earnings].size).to eq(1)
      end
    end

    describe 'monetary series' do
      it 'exposes every earning as a dated amount' do
        create(:earning, user: user, date: Date.new(2026, 6, 1), amount: 300.00)

        series = described_class.call(user: user).earnings

        expect(series.map(&:date)).to eq([Date.new(2026, 6, 1)])
        expect(series.map(&:amount)).to eq([300.0])
      end

      it 'exposes only paid expenses as a dated amount' do
        create(:expense, user: user, date: Date.new(2026, 6, 2), amount: 80.00, paid: true)
        create(:expense, user: user, date: Date.new(2026, 6, 3), amount: 40.00, paid: false)

        series = described_class.call(user: user).expenses

        expect(series.map(&:amount)).to eq([80.0])
      end
    end
  end
end
