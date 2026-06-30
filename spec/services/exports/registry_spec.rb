require 'rails_helper'

RSpec.describe Exports::Registry do
  describe '.for' do
    it 'resolves csv to Generators::Csv' do
      expect(described_class.for('csv')).to eq(Exports::Generators::Csv)
    end

    it 'resolves pdf to Generators::Pdf' do
      expect(described_class.for('pdf')).to eq(Exports::Generators::Pdf)
    end

    it 'resolves json to Generators::Json' do
      expect(described_class.for('json')).to eq(Exports::Generators::Json)
    end

    it 'accepts symbol keys' do
      expect(described_class.for(:csv)).to eq(Exports::Generators::Csv)
    end

    it 'raises UnknownFormat for missing key' do
      expect { described_class.for('zip') }.to raise_error(Exports::Registry::UnknownFormat, /zip/)
    end
  end
end
