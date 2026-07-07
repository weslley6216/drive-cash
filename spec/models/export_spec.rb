require 'rails_helper'

RSpec.describe Export, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'enums' do
    it {
      should define_enum_for(:period_kind).with_values(
        this_month: 0, last_month: 1, year: 2, custom: 3
      ).with_prefix.backed_by_column_of_type(:integer).validating
    }

    it {
      should define_enum_for(:format).with_values(
        pdf: 0, csv: 1, json: 2
      ).with_prefix.backed_by_column_of_type(:integer).validating
    }

    it {
      should define_enum_for(:status).with_values(
        pending: 0, processing: 1, done: 2, failed: 3
      ).with_prefix.backed_by_column_of_type(:integer).validating
    }
  end

  describe 'validations' do
    it 'requires period_kind' do
      export = build(:export, period_kind: nil)

      expect(export).not_to be_valid
    end

    it 'requires format' do
      export = build(:export, format: nil)

      expect(export).not_to be_valid
    end

    it 'requires period_end on or after period_start' do
      export = build(:export, period_kind: 'custom', period_start: Date.new(2026, 6, 30), period_end: Date.new(2026, 6, 1))

      export.valid?

      expect(export.errors[:period_end]).to be_present
    end
  end

  describe 'defaults' do
    it 'defaults includes to all true' do
      export = described_class.new

      expect(export.includes).to eq('earnings' => true, 'expenses' => true, 'refuelings' => true, 'maintenances' => false)
    end

    it 'defaults status to pending' do
      export = described_class.new

      expect(export.status_pending?).to be true
    end
  end

  describe '.recent' do
    it 'orders by created_at desc' do
      old_export = create(:export, created_at: 3.days.ago)
      new_export = create(:export, created_at: 1.hour.ago)

      result = described_class.recent

      expect(result.first).to eq(new_export)
      expect(result.last).to eq(old_export)
    end
  end

  describe '#file attachment' do
    it 'accepts an attached file' do
      export = create(:export)

      export.file.attach(io: StringIO.new('hello'), filename: 'test.csv', content_type: 'text/csv')

      expect(export.file).to be_attached
    end
  end

  describe 'period derivation from period_kind' do
    it 'derives period_start and period_end for this_month' do
      travel_to Date.new(2026, 6, 15) do
        export = create(:export, period_kind: 'this_month', period_start: nil, period_end: nil)

        expect(export.period_start).to eq(Date.new(2026, 6, 1))
        expect(export.period_end).to eq(Date.new(2026, 6, 30))
      end
    end

    it 'derives the previous month for last_month' do
      travel_to Date.new(2026, 6, 15) do
        export = create(:export, period_kind: 'last_month', period_start: nil, period_end: nil)

        expect(export.period_start).to eq(Date.new(2026, 5, 1))
        expect(export.period_end).to eq(Date.new(2026, 5, 31))
      end
    end

    it 'derives the current year for year' do
      travel_to Date.new(2026, 6, 15) do
        export = create(:export, period_kind: 'year', period_start: nil, period_end: nil)

        expect(export.period_start).to eq(Date.new(2026, 1, 1))
        expect(export.period_end).to eq(Date.new(2026, 12, 31))
      end
    end

    it 'keeps the provided dates for custom' do
      export = create(:export, period_kind: 'custom', period_start: Date.new(2026, 2, 1), period_end: Date.new(2026, 2, 28))

      expect(export.period_start).to eq(Date.new(2026, 2, 1))
      expect(export.period_end).to eq(Date.new(2026, 2, 28))
    end
  end

  describe '#resolve_period' do
    it 'derives period bounds explicitly for a known period_kind' do
      export = Export.new(period_kind: 'year')

      export.resolve_period

      expect(export.period_start).to eq(Date.current.beginning_of_year)
      expect(export.period_end).to eq(Date.current.end_of_year)
    end

    it 'does nothing for an unknown period_kind' do
      export = Export.new
      export.period_kind = 'x'

      export.resolve_period

      expect(export.period_start).to be_nil
    end
  end
end
