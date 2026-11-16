require 'rails_helper'

RSpec.describe Llm::Adapters::Gemini do
  subject(:adapter) { described_class.new }

  let(:messages) { [{ role: 'user', content: 'Hello' }] }
  let(:response_mock) { instance_double(Faraday::Response) }
  let(:connection_mock) { instance_double(Faraday::Connection) }
  let(:builder_mock) { double('FaradayBuilder', request: true, response: true, adapter: true) }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('GEMINI_API_KEY').and_return('fake-key')
    allow(ENV).to receive(:fetch).with('GEMINI_MODEL', anything).and_return('gemini-test')
    allow(Faraday).to receive(:new).and_yield(builder_mock).and_return(connection_mock)
    allow(connection_mock).to receive(:post).and_return(response_mock)
  end

  describe '#chat' do
    context 'when the API returns a text response' do
      before do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'candidates' => [{ 'content' => { 'parts' => [{ 'text' => 'Hello!' }] } }]
        })
      end

      it 'returns a normalized hash with type :text' do
        result = adapter.chat(messages: messages)

        expect(result).to eq({ type: :text, content: 'Hello!' })
      end
    end

    context 'when the API returns a tool call' do
      before do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'candidates' => [{
            'content' => { 'parts' => [{
              'functionCall' => { 'name' => 'create_expense', 'args' => { 'amount' => 45, 'category' => 'fuel' } }
            }] }
          }]
        })
      end

      it 'returns a normalized hash with type :tool_use and preserves the JSON-parsed amount type' do
        result = adapter.chat(messages: messages)

        expect(result).to eq({
          type:        :tool_use,
          tool_name:   'create_expense',
          tool_input:  { 'amount' => 45, 'category' => 'fuel' },
          text_before: nil
        })
        expect(result[:tool_input]['amount']).to be_a(Integer)
      end
    end

    context 'when LLM returns text alongside a function call' do
      it 'includes text_before in the result' do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'candidates' => [{
            'content' => {
              'parts' => [
                { 'text' => 'E o iFood de R$ 45, registro também?' },
                { 'functionCall' => { 'name' => 'create_earning', 'args' => { 'amount' => 80 } } }
              ]
            }
          }]
        })

        result = adapter.chat(messages: messages)

        expect(result[:text_before]).to eq('E o iFood de R$ 45, registro também?')
      end

      it 'sets text_before to nil when no text parts exist' do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'candidates' => [{
            'content' => {
              'parts' => [
                { 'functionCall' => { 'name' => 'create_earning', 'args' => { 'amount' => 80 } } }
              ]
            }
          }]
        })

        result = adapter.chat(messages: messages)

        expect(result[:text_before]).to be_nil
      end
    end

    context 'when the API returns 503' do
      before do
        allow(response_mock).to receive(:status).and_return(503)
        allow(response_mock).to receive(:body).and_return({ 'error' => { 'message' => 'High demand' } })
      end

      it 'raises Llm::RateLimitError' do
        expect { adapter.chat(messages: messages) }.to raise_error(Llm::RateLimitError)
      end
    end

    context 'when the free tier daily quota is exhausted' do
      before do
        allow(response_mock).to receive(:status).and_return(429)
        allow(response_mock).to receive(:body).and_return({
          'error' => {
            'code'    => 429,
            'message' => 'You exceeded your current quota, please check your plan and billing details.',
            'status'  => 'RESOURCE_EXHAUSTED',
            'details' => [
              {
                '@type'      => 'type.googleapis.com/google.rpc.QuotaFailure',
                'violations' => [{
                  'quotaMetric' => 'generativelanguage.googleapis.com/generate_content_free_tier_requests',
                  'quotaId'     => 'GenerateRequestsPerDayPerProjectPerModel-FreeTier',
                  'quotaValue'  => '20'
                }]
              },
              { '@type' => 'type.googleapis.com/google.rpc.RetryInfo', 'retryDelay' => '33606s' }
            ]
          }
        })
      end

      it 'raises Llm::QuotaExhaustedError' do
        expect { adapter.chat(messages: messages) }.to raise_error(Llm::QuotaExhaustedError, /exceeded your current quota/)
      end
    end

    context 'when the per-minute quota is exceeded' do
      before do
        allow(response_mock).to receive(:status).and_return(429)
        allow(response_mock).to receive(:body).and_return({
          'error' => {
            'code'    => 429,
            'message' => 'You exceeded your current quota, please check your plan and billing details.',
            'status'  => 'RESOURCE_EXHAUSTED',
            'details' => [{
              '@type'      => 'type.googleapis.com/google.rpc.QuotaFailure',
              'violations' => [{ 'quotaId' => 'GenerateRequestsPerMinutePerProjectPerModel-FreeTier' }]
            }]
          }
        })
      end

      it 'raises a plain Llm::RateLimitError' do
        expect { adapter.chat(messages: messages) }.to raise_error { |error| expect(error.class).to eq(Llm::RateLimitError) }
      end
    end

    context 'when GEMINI_MODEL is not set' do
      before do
        allow(ENV).to receive(:fetch).with('GEMINI_MODEL', anything) { |_key, default| default }
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({ 'candidates' => [] })
      end

      it 'requests the gemini-3-flash-preview model' do
        adapter.chat(messages: messages)

        expect(connection_mock).to have_received(:post).with(%r{/models/gemini-3-flash-preview:generateContent}, anything)
      end
    end

    context 'when the API returns a generic error' do
      before do
        allow(response_mock).to receive(:status).and_return(400)
        allow(response_mock).to receive(:body).and_return({ 'error' => { 'message' => 'Invalid payload' } })
      end

      it 'raises Llm::Error' do
        expect { adapter.chat(messages: messages) }.to raise_error(Llm::Error, /Invalid payload/)
      end
    end

    context 'when GEMINI_API_KEY is not set' do
      before { allow(ENV).to receive(:fetch).with('GEMINI_API_KEY').and_yield }

      it 'raises Llm::ConfigurationError' do
        expect { adapter.chat(messages: messages) }.to raise_error(Llm::ConfigurationError, /GEMINI_API_KEY is not set/)
      end
    end
  end
end
