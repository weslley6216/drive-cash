require 'rails_helper'

RSpec.describe Ai::FuelVendorName do
  describe '.call' do
    it 'prefixes Posto to the vendor of a fuel expense' do
      params = { 'category' => 'fuel', 'vendor' => 'Ipiranga', 'amount' => 45 }

      expect(described_class.call(params)).to eq({ 'category' => 'fuel', 'vendor' => 'Posto Ipiranga', 'amount' => 45 })
    end

    it 'keeps a fuel vendor that already starts with posto, capitalizing the word' do
      expect(described_class.call({ 'category' => 'fuel', 'vendor' => 'posto Shell' })['vendor']).to eq('Posto Shell')
    end

    it 'does not take a vendor that only begins with the letters of posto as prefixed' do
      expect(described_class.call({ 'category' => 'fuel', 'vendor' => 'Postão da BR' })['vendor']).to eq('Posto Postão da BR')
    end

    it 'leaves the vendor of other categories untouched' do
      params = { 'category' => 'maintenance', 'vendor' => 'Carmaniacs' }

      expect(described_class.call(params)).to eq(params)
    end

    it 'leaves a fuel expense without vendor untouched' do
      params = { 'category' => 'fuel', 'amount' => 45 }

      expect(described_class.call(params)).to eq(params)
    end
  end
end
