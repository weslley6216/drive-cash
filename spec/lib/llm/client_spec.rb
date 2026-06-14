require 'rails_helper'

RSpec.describe Llm::Client do
  let(:messages) { [{ role: 'user', content: 'Hello' }] }
  let(:groq_adapter) { instance_double(Llm::Adapters::Groq) }
  let(:gemini_adapter) { instance_double(Llm::Adapters::Gemini) }

  before do
    allow(Llm::Adapters::Groq).to receive(:new).and_return(groq_adapter)
    allow(Llm::Adapters::Gemini).to receive(:new).and_return(gemini_adapter)
  end

  describe '.chat' do
    context 'when LLM_PROVIDER is not set' do
      before { stub_const('ENV', ENV.to_h.merge('LLM_PROVIDER' => nil, 'LLM_FALLBACK' => nil)) }

      it 'raises ConfigurationError' do
        expect { described_class.chat(messages: messages) }.to raise_error(Llm::ConfigurationError, /LLM_PROVIDER is not set/)
      end
    end

    context 'when LLM_PROVIDER=groq and Groq succeeds' do
      before { stub_const('ENV', ENV.to_h.merge('LLM_PROVIDER' => 'groq', 'LLM_FALLBACK' => nil)) }

      it 'returns Groq response without calling Gemini' do
        expect(groq_adapter).to receive(:chat).and_return({ type: :text, content: 'Groq response' })
        expect(gemini_adapter).not_to receive(:chat)

        result = described_class.chat(messages: messages)

        expect(result[:content]).to eq('Groq response')
      end
    end

    context 'when LLM_PROVIDER=groq, LLM_FALLBACK=gemini and Groq fails' do
      before { stub_const('ENV', ENV.to_h.merge('LLM_PROVIDER' => 'groq', 'LLM_FALLBACK' => 'gemini')) }

      it 'falls back to Gemini automatically' do
        allow(groq_adapter).to receive(:chat).and_raise(Llm::RateLimitError, 'Groq busy')
        expect(gemini_adapter).to receive(:chat).and_return({ type: :text, content: 'Gemini response' })

        result = described_class.chat(messages: messages)

        expect(result[:content]).to eq('Gemini response')
      end
    end

    context 'when all providers fail' do
      before { stub_const('ENV', ENV.to_h.merge('LLM_PROVIDER' => 'groq', 'LLM_FALLBACK' => 'gemini')) }

      it 'raises the last captured error' do
        allow(groq_adapter).to receive(:chat).and_raise(Llm::Error, 'Groq error')
        allow(gemini_adapter).to receive(:chat).and_raise(Llm::Error, 'Gemini error')

        expect {
          described_class.chat(messages: messages)
        }.to raise_error(Llm::Error, 'Gemini error')
      end
    end

    context 'when an unknown provider is configured' do
      before { stub_const('ENV', ENV.to_h.merge('LLM_PROVIDER' => 'unknown_ai')) }

      it 'raises ConfigurationError' do
        expect { described_class.chat(messages: messages) }.to raise_error(Llm::ConfigurationError, /Unknown LLM provider/)
      end
    end
  end
end
