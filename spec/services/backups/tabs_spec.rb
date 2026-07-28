require 'rails_helper'

RSpec.describe Backups::Tabs do
  describe 'ALL' do
    it 'starts with the summary tab so it opens first in the spreadsheet' do
      expect(described_class::ALL.first.key).to eq(:summary)
    end

    it 'covers every mirrored tab plus the summary' do
      expect(described_class::ALL.map(&:key))
        .to eq(%i[summary earnings expenses refuelings maintenances goals])
    end

    it 'uses unique titles' do
      titles = described_class::ALL.map(&:title)

      expect(titles.uniq.size).to eq(titles.size)
    end
  end

  describe '.find' do
    it 'returns the tab for a known key' do
      expect(described_class.find(:earnings).title).to eq('Ganhos')
    end

    it 'raises for an unknown key' do
      expect { described_class.find(:unknown) }.to raise_error(described_class::UnknownTab, /unknown/)
    end
  end

  describe 'Tab' do
    let(:tab) { described_class.find(:refuelings) }

    it 'translates the title' do
      expect(tab.title).to eq('Abastecimentos')
    end

    it 'translates every column header in declaration order' do
      expect(tab.headers)
        .to eq(['Data', 'Posto', 'Litros', 'Preço/litro', 'Total', 'Odômetro (km)', 'Tanque cheio'])
    end

    it 'reports its width' do
      expect(tab.width).to eq(7)
    end

    it 'locates a column by name' do
      expect(described_class.find(:summary).index_of(:profit)).to eq(3)
    end

    it 'exposes the summary savings header as an estimate' do
      expect(described_class.find(:summary).headers.last).to eq('% para Conta (estimado)')
    end
  end

  describe 'formats' do
    it 'formats money columns as brazilian currency' do
      amount = described_class.find(:earnings).columns.find { |column| column.name == :amount }

      expect(amount.format.type).to eq('CURRENCY')
      expect(amount.format.pattern).to eq('"R$" #,##0.00')
    end

    it 'formats date columns as day-first' do
      date = described_class.find(:earnings).columns.find { |column| column.name == :date }

      expect(date.format.pattern).to eq('dd/mm/yyyy')
    end

    it 'keeps a third decimal on the fuel unit price' do
      price = described_class.find(:refuelings).columns.find { |column| column.name == :price_per_liter }

      expect(price.format.pattern).to eq('"R$" #,##0.000')
    end

    it 'leaves text columns without a number format' do
      notes = described_class.find(:earnings).columns.find { |column| column.name == :notes }

      expect(notes.format).to be_nil
    end
  end
end
