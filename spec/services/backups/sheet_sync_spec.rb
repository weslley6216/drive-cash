require 'rails_helper'

RSpec.describe Backups::SheetSync do
  let(:user) { create(:user, email_address: 'driver@gmail.com') }
  let(:client) { instance_double(Google::Apis::SheetsV4::SheetsService) }
  let(:writer) { instance_double(Backups::SheetWriter, call: true) }
  let(:writer_class) { class_double(Backups::SheetWriter, new: writer) }
  let(:config) do
    instance_double(Backups::Config, target_email: 'driver@gmail.com', spreadsheet_id: '1AbC', savings_percentage: 35)
  end

  describe '.call' do
    it 'writes the snapshot rows and the derived summary to the configured spreadsheet' do
      create(:earning, user: user, date: Date.new(2026, 1, 5), amount: 1_000.00, platform: 'uber')
      create(:expense, user: user, date: Date.new(2026, 1, 6), amount: 200.00, category: 'fuel', paid: true)

      described_class.call(config: config, client: client, writer_class: writer_class)

      expect(writer_class).to have_received(:new) do |args|
        expect(args[:client]).to eq(client)
        expect(args[:spreadsheet_id]).to eq('1AbC')
        expect(args[:rows][:earnings].first[1]).to eq('Uber')
        expect(args[:rows][:summary].first).to eq(['2026-01', 1_000.0, 200.0, 800.0, 280.0])
        expect(args[:summary_month_count]).to eq(1)
      end
      expect(writer).to have_received(:call)
    end

    it 'writes an empty summary when the user has no records' do
      user

      described_class.call(config: config, client: client, writer_class: writer_class)

      expect(writer_class).to have_received(:new) do |args|
        expect(args[:rows][:summary]).to eq([])
        expect(args[:summary_month_count]).to eq(0)
      end
    end

    it 'raises when no user matches the configured email' do
      expect { described_class.call(config: config, client: client, writer_class: writer_class) }
        .to raise_error(described_class::MissingUser, /driver@gmail.com/)
    end

    it 'does not touch the spreadsheet when the user is missing' do
      expect { described_class.call(config: config, client: client, writer_class: writer_class) }
        .to raise_error(described_class::MissingUser)

      expect(writer_class).not_to have_received(:new)
    end
  end
end
