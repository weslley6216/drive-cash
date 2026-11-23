require 'rails_helper'

RSpec.describe Ai::Tools::CreateRecords do
  let(:declaration) { described_class.declaration }
  let(:record_schema) { declaration[:parameters][:properties][:records][:items] }

  describe '.declaration' do
    it 'asks for a list of records in a single required parameter' do
      expect(declaration[:name]).to eq('create_records')
      expect(declaration[:parameters][:required]).to eq(['records'])
      expect(declaration[:parameters][:properties][:records][:type]).to eq('ARRAY')
    end

    it 'restricts each record action to the earning and expense tools' do
      expect(record_schema[:properties][:action][:enum]).to eq(%w[create_earning create_expense])
    end

    it 'offers every earning and expense field on each record' do
      fields = Ai::Tools::CreateEarning.declaration[:parameters][:properties].keys |
               Ai::Tools::CreateExpense.declaration[:parameters][:properties].keys

      expect(record_schema[:properties].keys).to include(*fields)
    end

    it 'requires only the fields shared by both record kinds' do
      expect(record_schema[:required]).to eq(%w[action amount date])
    end
  end

  describe '.expand' do
    it 'turns each record of a create_records call into its own tool call' do
      calls = [{ name: 'create_records', input: { 'records' => [
        { 'action' => 'create_earning', 'amount' => 120, 'platform' => 'shopee', 'date' => '2026-11-16' },
        { 'action' => 'create_expense', 'amount' => 60, 'category' => 'fuel', 'vendor' => 'Ipiranga', 'date' => '2026-11-16' }
      ] } }]

      expect(described_class.expand(calls)).to eq([
        { name: 'create_earning', input: { 'amount' => 120, 'platform' => 'shopee', 'date' => '2026-11-16' } },
        { name: 'create_expense', input: { 'amount' => 60, 'category' => 'fuel', 'vendor' => 'Ipiranga', 'date' => '2026-11-16' } }
      ])
    end

    it 'drops the null fields of each record' do
      calls = [{ name: 'create_records', input: { 'records' => [
        { 'action' => 'create_earning', 'amount' => 100, 'platform' => 'uber', 'date' => '2026-11-23', 'notes' => nil }
      ] } }]

      expect(described_class.expand(calls).first[:input]).to eq({ 'amount' => 100, 'platform' => 'uber', 'date' => '2026-11-23' })
    end

    it 'keeps the other tool calls as they are' do
      calls = [{ name: 'create_goal', input: { 'kind' => 'weekly', 'target_amount' => 500 } }]

      expect(described_class.expand(calls)).to eq(calls)
    end
  end
end
