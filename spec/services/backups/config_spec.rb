require 'rails_helper'

RSpec.describe Backups::Config do
  around do |example|
    original = ENV.to_hash
    example.run
    ENV.replace(original)
  end

  describe '#service_account_json' do
    it 'returns the raw env value' do
      ENV['GOOGLE_BACKUP_SA_JSON'] = '{"type":"service_account"}'

      expect(described_class.new.service_account_json).to eq('{"type":"service_account"}')
    end

    it 'raises when the variable is missing' do
      ENV.delete('GOOGLE_BACKUP_SA_JSON')

      expect { described_class.new.service_account_json }
        .to raise_error(Backups::ConfigurationError, /GOOGLE_BACKUP_SA_JSON/)
    end
  end

  describe '#spreadsheet_id' do
    it 'returns the raw env value' do
      ENV['GOOGLE_BACKUP_SPREADSHEET_ID'] = '1AbC'

      expect(described_class.new.spreadsheet_id).to eq('1AbC')
    end

    it 'raises when the variable is blank' do
      ENV['GOOGLE_BACKUP_SPREADSHEET_ID'] = ''

      expect { described_class.new.spreadsheet_id }
        .to raise_error(Backups::ConfigurationError, /GOOGLE_BACKUP_SPREADSHEET_ID/)
    end
  end

  describe '#target_email' do
    it 'returns the raw env value' do
      ENV['BACKUP_TARGET_EMAIL'] = 'driver@example.com'

      expect(described_class.new.target_email).to eq('driver@example.com')
    end

    it 'raises when the variable is missing' do
      ENV.delete('BACKUP_TARGET_EMAIL')

      expect { described_class.new.target_email }
        .to raise_error(Backups::ConfigurationError, /BACKUP_TARGET_EMAIL/)
    end
  end

  describe '#savings_percentage' do
    it 'casts the env value to an integer' do
      ENV['BACKUP_SAVINGS_PERCENTAGE'] = '40'

      expect(described_class.new.savings_percentage).to eq(40)
    end

    it 'falls back to 35 when the variable is missing' do
      ENV.delete('BACKUP_SAVINGS_PERCENTAGE')

      expect(described_class.new.savings_percentage).to eq(35)
    end
  end
end
