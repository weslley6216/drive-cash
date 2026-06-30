require 'rails_helper'

RSpec.describe Export, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'enums' do
    it {
      should define_enum_for(:period_kind).with_values(
        this_month: 0, last_month: 1, year: 2, custom: 3
      ).with_prefix.backed_by_column_of_type(:integer)
    }

    it {
      should define_enum_for(:format).with_values(
        pdf: 0, csv: 1, json: 2
      ).with_prefix.backed_by_column_of_type(:integer)
    }

    it {
      should define_enum_for(:status).with_values(
        pending: 0, processing: 1, done: 2, failed: 3
      ).with_prefix.backed_by_column_of_type(:integer)
    }
  end

  describe 'validations' do
    subject { build(:export) }

    it { is_expected.to validate_presence_of(:period_start) }
    it { is_expected.to validate_presence_of(:period_end) }
    it { is_expected.to validate_presence_of(:period_kind) }
    it { is_expected.to validate_presence_of(:format) }

    it 'requires period_end on or after period_start' do
      export = build(:export, period_start: Date.new(2026, 6, 30), period_end: Date.new(2026, 6, 1))

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
end
