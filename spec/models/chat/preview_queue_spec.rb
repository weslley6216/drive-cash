require 'rails_helper'

RSpec.describe Chat::PreviewQueue do
  let(:shopee) do
    {
      type:        :preview,
      action:      'create_earning',
      params:      { 'amount' => 120, 'platform' => 'shopee', 'date' => '2026-11-16' },
      summary:     'Receita de R$ 120,00 via Shopee em 16/11/2026',
      content:     'Registro apresentado ao usuário para confirmação: Shopee',
      text_before: 'Bora registrar os dois!'
    }
  end
  let(:ipiranga) do
    {
      type:    :preview,
      action:  'create_expense',
      params:  { 'amount' => 60, 'category' => 'fuel', 'vendor' => 'Ipiranga', 'date' => '2026-11-16' },
      summary: 'Despesa de R$ 60,00 (Combustível — Ipiranga) em 16/11/2026',
      content: 'Registro apresentado ao usuário para confirmação: Ipiranga'
    }
  end
  let(:batch) { described_class.from_result(shopee.merge(queued: [ipiranga])) }

  describe '.from_result' do
    it 'puts the result preview at the head followed by the queued previews' do
      expect(batch.head).to eq(shopee)
      expect(batch.advance.head).to eq(ipiranga)
    end

    it 'counts every preview of the result as the batch size' do
      expect(batch.batch_size).to eq(2)
    end

    it 'starts empty when the result is not a preview' do
      queue = described_class.from_result({ type: :text, content: 'Em qual posto você abasteceu?' })

      expect(queue).to be_empty
      expect(queue.head).to be_nil
    end
  end

  describe '#batch?' do
    it 'is true for two or more previews' do
      expect(batch.batch?).to be(true)
    end

    it 'is false for a single preview' do
      expect(described_class.from_result(shopee).batch?).to be(false)
    end
  end

  describe '#advance' do
    it 'drops the head and keeps the batch size' do
      queue = batch.advance.advance

      expect(queue).to be_empty
      expect(queue.batch_size).to eq(2)
    end

    it 'stays empty when advancing an empty queue' do
      expect(described_class.from_session(nil).advance).to be_empty
    end
  end

  describe 'session round-trip' do
    it 'restores the same previews and batch size from a serialized session hash' do
      restored = described_class.from_session(JSON.parse(batch.to_session_hash.to_json))

      expect(restored.head).to eq(shopee)
      expect(restored.advance.head).to eq(ipiranga)
      expect(restored.batch_size).to eq(2)
    end

    it 'builds an empty queue when the session has none' do
      expect(described_class.from_session(nil)).to be_empty
    end
  end
end
