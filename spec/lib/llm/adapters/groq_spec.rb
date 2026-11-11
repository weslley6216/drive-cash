require 'rails_helper'

RSpec.describe Llm::Adapters::Groq do
  subject(:adapter) { described_class.new }

  let(:messages) { [{ role: 'user', content: 'Hello' }] }
  let(:response_mock) { instance_double(Faraday::Response) }
  let(:connection_mock) { instance_double(Faraday::Connection) }

  let(:builder_mock) { double('FaradayBuilder', request: true, response: true, adapter: true) }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('GROQ_API_KEY').and_return('fake-key')
    allow(ENV).to receive(:fetch).with('GROQ_MODEL', anything).and_return('groq-test-model')
    allow(Faraday).to receive(:new).and_yield(builder_mock).and_return(connection_mock)
    allow(connection_mock).to receive(:post).and_return(response_mock)
  end

  describe '#chat' do
    context 'when the API returns a text response' do
      before do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{ 'message' => { 'content' => 'Hello!' } }]
        })
      end

      it 'returns a normalized hash with type :text' do
        result = adapter.chat(messages: messages)

        expect(result).to eq({ type: :text, content: 'Hello!' })
      end
    end

    context 'when the text response leaks function syntax' do
      before { allow(response_mock).to receive(:status).and_return(200) }

      it 'strips XML-style function tags from the content' do
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{ 'message' => { 'content' => 'Hello <function name="test">body</function> world' } }]
        })

        result = adapter.chat(messages: messages)

        expect(result[:content]).to eq('Hello  world')
      end

      it 'strips JSON-style field leaks from the content' do
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{ 'message' => { 'content' => 'Done. {"amount": 50.0} ok' } }]
        })

        result = adapter.chat(messages: messages)

        expect(result[:content]).to eq('Done.  ok')
      end
    end

    context 'when the API returns a tool call' do
      before do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{ 'message' => {
            'tool_calls' => [{ 'function' => { 'name' => 'create_expense', 'arguments' => '{"amount":45}' } }]
          } }]
        })
      end

      it 'returns a normalized hash with type :tool_use and preserves the JSON-parsed amount type' do
        result = adapter.chat(messages: messages)

        expect(result[:type]).to eq(:tool_use)
        expect(result[:tool_name]).to eq('create_expense')
        expect(result[:tool_input]).to eq({ 'amount' => 45 })
        expect(result[:tool_input]['amount']).to be_a(Integer)
      end
    end

    context 'when the tool call arguments are malformed JSON' do
      before do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{ 'message' => {
            'tool_calls' => [{ 'function' => { 'name' => 'f', 'arguments' => '{' } }]
          } }]
        })
      end

      it 'returns an empty text response' do
        result = adapter.chat(messages: messages)

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq('')
      end
    end

    context 'when the API returns 429' do
      before do
        allow(response_mock).to receive(:status).and_return(429)
        allow(response_mock).to receive(:body).and_return({ 'error' => { 'message' => 'Rate limit' } })
      end

      it 'raises Llm::RateLimitError' do
        expect { adapter.chat(messages: messages) }.to raise_error(Llm::RateLimitError)
      end
    end

    context 'when the API returns a generic error' do
      before do
        allow(response_mock).to receive(:status).and_return(400)
        allow(response_mock).to receive(:body).and_return({ 'error' => { 'message' => 'Bad Request' } })
      end

      it 'raises Llm::Error' do
        expect { adapter.chat(messages: messages) }.to raise_error(Llm::Error, /Bad Request/)
      end
    end

    context 'when GROQ_API_KEY is not set' do
      before { allow(ENV).to receive(:fetch).with('GROQ_API_KEY').and_yield }

      it 'raises Llm::ConfigurationError' do
        expect { adapter.chat(messages: messages) }.to raise_error(Llm::ConfigurationError, /GROQ_API_KEY is not set/)
      end
    end

    context 'when LLM returns text alongside a tool call' do
      it 'includes text_before in the result' do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{
            'message' => {
              'tool_calls' => [{ 'function' => { 'name' => 'create_earning', 'arguments' => '{"amount":80}' } }],
              'content'    => 'E o iFood de R$ 45, registro também?'
            }
          }]
        })

        result = adapter.chat(messages: messages)

        expect(result[:text_before]).to eq('E o iFood de R$ 45, registro também?')
      end

      it 'sets text_before to nil when content is blank' do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{
            'message' => {
              'tool_calls' => [{ 'function' => { 'name' => 'create_earning', 'arguments' => '{"amount":80}' } }],
              'content'    => nil
            }
          }]
        })

        result = adapter.chat(messages: messages)

        expect(result[:text_before]).to be_nil
      end
    end

    context 'when GROQ_MODEL is not set' do
      before do
        allow(ENV).to receive(:fetch).with('GROQ_MODEL', anything) { |_key, default| default }
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({})
      end

      it 'sends the default gpt-oss-120b model in the payload' do
        adapter.chat(messages: messages)

        expect(connection_mock).to have_received(:post).with('chat/completions', hash_including(model: 'openai/gpt-oss-120b'))
      end
    end

    context 'when GROQ_MODEL is set' do
      before do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({})
      end

      it 'sends the configured model in the payload' do
        adapter.chat(messages: messages)

        expect(connection_mock).to have_received(:post).with('chat/completions', hash_including(model: 'groq-test-model'))
      end
    end

    context 'when the response carries a separate reasoning field' do
      before { allow(response_mock).to receive(:status).and_return(200) }

      it 'keeps the reasoning out of text_before on a tool call' do
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{ 'message' => {
            'reasoning'  => 'The user spent 50 on fuel, call create_expense.',
            'content'    => nil,
            'tool_calls' => [{ 'function' => { 'name' => 'create_expense', 'arguments' => '{"amount":50}' } }]
          } }]
        })

        result = adapter.chat(messages: messages)

        expect(result).to include(type: :tool_use, tool_name: 'create_expense', tool_input: { 'amount' => 50 }, text_before: nil)
      end

      it 'returns only the content on a text answer' do
        allow(response_mock).to receive(:body).and_return({
          'choices' => [{ 'message' => {
            'reasoning' => 'The user asks about earnings.',
            'content'   => 'Você ganhou R$ 120 este mês.'
          } }]
        })

        result = adapter.chat(messages: messages)

        expect(result).to eq({ type: :text, content: 'Você ganhou R$ 120 este mês.' })
      end
    end

    context 'when tools are provided' do
      let(:tools) do
        [{
          name:       'test_tool',
          parameters: { type: 'OBJECT', properties: { amount: { type: 'STRING' } } }
        }]
      end

      it 'normalizes the schema types to lowercase and sends them in the payload' do
        allow(response_mock).to receive(:status).and_return(200)
        allow(response_mock).to receive(:body).and_return({})

        expect(connection_mock).to receive(:post).with(
          'chat/completions',
          hash_including(
            tools: [{
              type:     'function',
              function: {
                name:       'test_tool',
                parameters: { type: 'object', properties: { amount: { type: 'string' } } }
              }
            }]
          )
        ).and_return(response_mock)

        adapter.chat(messages: messages, tools: tools)
      end
    end
  end
end
