require 'rails_helper'

RSpec.describe Chat::Message do
  describe '.from_user' do
    it 'keeps the spoken flag in the session hash of a voice message' do
      message = described_class.from_user('abasteci 80', voice: true)

      expect(message.to_session_hash).to eq(role: 'user', content: 'abasteci 80', voice: true)
    end

    it 'leaves the spoken flag out of a typed message' do
      message = described_class.from_user('abasteci 80')

      expect(message.to_session_hash).to eq(role: 'user', content: 'abasteci 80')
    end
  end

  describe '.from_result' do
    it 'never marks an assistant message as spoken' do
      message = described_class.from_result({ type: :text, content: 'Anotado' }, fallback_content: 'x')

      expect(message.to_session_hash).to eq(role: 'assistant', content: 'Anotado', type: :text)
    end
  end
end
