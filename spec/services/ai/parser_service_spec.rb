require 'rails_helper'

RSpec.describe Ai::ParserService do
  let(:messages) { [{ role: 'user', content: 'user input' }] }
  let(:client) { class_double(Llm::Client) }
  let(:service) { described_class.new(messages: messages, today: Date.new(2026, 4, 21), client: client) }

  describe '#call' do
    context 'when the LLM returns plain text' do
      before do
        allow(client).to receive(:chat).and_return({ type: :text, content: 'All good!' })
      end

      it 'passes the text response through' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq('All good!')
      end
    end

    context 'when the LLM returns the create_expense tool' do
      before do
        allow(client).to receive(:chat).and_return({
          type:       :tool_use,
          tool_name:  'create_expense',
          tool_input: { 'amount' => 45.0, 'category' => 'fuel', 'date' => '2026-04-21' }
        })
      end

      it 'builds an expense preview with raw params and a summary that includes amount, category and date' do
        result = service.call

        expect(result[:type]).to eq(:preview)
        expect(result[:action]).to eq('create_expense')
        expect(result[:params]['amount']).to eq(45.0)
        expect(result[:summary]).to include('R$ 45,00')
        expect(result[:summary]).to include(I18n.t('activerecord.attributes.expense.categories.fuel'))
        expect(result[:summary]).to include('21/04/2026')
      end
    end

    context 'when the LLM returns the create_earning tool' do
      before do
        allow(client).to receive(:chat).and_return({
          type:       :tool_use,
          tool_name:  'create_earning',
          tool_input: { 'amount' => 100.0, 'platform' => 'uber', 'date' => '2026-04-21' }
        })
      end

      it 'builds an earning preview with raw params and a summary that includes amount, platform and date' do
        result = service.call

        expect(result[:type]).to eq(:preview)
        expect(result[:action]).to eq('create_earning')
        expect(result[:params]['amount']).to eq(100.0)
        expect(result[:summary]).to include('R$ 100,00')
        expect(result[:summary]).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
        expect(result[:summary]).to include('21/04/2026')
      end
    end

    context 'when the LLM returns the create_earning tool with an invalid date' do
      before do
        allow(client).to receive(:chat).and_return({
          type:       :tool_use,
          tool_name:  'create_earning',
          tool_input: { 'amount' => 100.0, 'platform' => 'uber', 'date' => 'not-a-date' }
        })
      end

      it 'returns the raw date string without raising' do
        result = service.call

        expect(result[:type]).to eq(:preview)
        expect(result[:params]['date']).to eq('not-a-date')
      end
    end

    context 'when the LLM returns the create_expense tool with an invalid amount' do
      before do
        allow(client).to receive(:chat).and_return({
          type:       :tool_use,
          tool_name:  'create_expense',
          tool_input: { 'amount' => 0.0, 'category' => 'fuel', 'date' => '2026-04-21' }
        })
      end

      it 'returns the missing_amount message' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.errors.missing_amount'))
      end
    end

    context 'when the LLM returns an unregistered tool' do
      before do
        allow(client).to receive(:chat).and_return({
          type:       :tool_use,
          tool_name:  'delete_everything',
          tool_input: { 'amount' => 10.0 }
        })
      end

      it 'returns the fallback message' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.message.fallback'))
      end
    end

    context 'when the LLM returns an invalid JSON tool input' do
      before do
        allow(client).to receive(:chat).and_return({
          type:       :tool_use,
          tool_name:  'create_expense',
          tool_input: '{ amount: 50, category: }'
        })
      end

      it 'rescues JSON::ParserError and returns the fallback message' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.message.fallback'))
      end
    end

    context 'when the LLM returns an unknown response type' do
      before do
        allow(client).to receive(:chat).and_return({ type: :unknown, content: '???' })
      end

      it 'returns the not_understood fallback' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.message.not_understood'))
      end

      it 'logs the response type without leaking the content' do
        logged = nil
        allow(Rails.logger).to receive(:warn) { |message| logged = message }

        service.call

        expect(logged).to include('unknown')
        expect(logged).not_to include('???')
      end
    end

    context 'when the LLM raises a RateLimitError' do
      before do
        allow(client).to receive(:chat).and_raise(Llm::RateLimitError.new('busy'))
      end

      it 'returns the rate limit message' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.errors.rate_limit'))
      end
    end

    context 'when the LLM raises a ConfigurationError' do
      before do
        allow(client).to receive(:chat).and_raise(Llm::ConfigurationError.new('no key'))
      end

      it 'returns the misconfiguration message as a text response' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.errors.misconfig'))
      end
    end

    context 'when the LLM raises a generic API error' do
      before do
        allow(client).to receive(:chat).and_raise(Llm::Error.new('bad gateway'))
      end

      it 'returns the api error message as a text response' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.errors.api_error'))
      end
    end

    context 'when an unexpected StandardError is raised' do
      before do
        allow(client).to receive(:chat).and_raise(StandardError.new('disk full'))
      end

      it 'returns the generic unexpected error message as a text response' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.errors.unexpected'))
      end
    end

    context 'when LLM returns the consolidated query tool' do
      let(:user) { create(:user) }
      let(:reader_double) { instance_double('reader', call: { profit: 1000.0 }) }
      let(:presenter_double) { instance_double('presenter', call: 'Lucro: R$ 1.000,00') }
      let(:reader_class) { class_double('Ai::Readers::Summary', new: reader_double) }
      let(:presenter_class) { class_double('Chat::Answers::Summary', new: presenter_double) }

      let(:service) { described_class.new(messages: messages, today: Date.new(2026, 6, 1), client: client, user: user) }

      before do
        allow(Ai::Tools::Registry).to receive(:query_kind).with('summary').and_return(
          Ai::Tools::Registry::QueryKind.new(reader: reader_class, answer_presenter: presenter_class)
        )
        allow(client).to receive(:chat).and_return({
          type: :tool_use, tool_name: 'query', tool_input: { 'type' => 'summary', 'year' => 2026, 'month' => 6 }
        })
      end

      it 'returns type :answer with the presenter content' do
        result = service.call

        expect(result[:type]).to eq(:answer)
        expect(result[:content]).to eq('Lucro: R$ 1.000,00')
      end

      it 'passes user and full params (including type) to the reader' do
        service.call

        expect(reader_class).to have_received(:new).with(
          { 'type' => 'summary', 'year' => 2026, 'month' => 6 }, user: user
        )
      end

      context 'when the reader raises an error' do
        before do
          allow(reader_class).to receive(:new).and_raise(StandardError, 'connection refused')
        end

        it 'rescues and returns api_error text' do
          result = service.call

          expect(result[:type]).to eq(:text)
          expect(result[:content]).to eq(I18n.t('chat.errors.api_error'))
        end
      end
    end

    context 'when LLM returns a query with an unknown type' do
      before do
        allow(client).to receive(:chat).and_return({
          type: :tool_use, tool_name: 'query', tool_input: { 'type' => 'not_a_kind' }
        })
      end

      it 'returns the fallback message' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.message.fallback'))
      end
    end

    context 'when LLM returns a query without a type' do
      before do
        allow(client).to receive(:chat).and_return({
          type: :tool_use, tool_name: 'query', tool_input: {}
        })
      end

      it 'returns the fallback message' do
        result = service.call

        expect(result[:type]).to eq(:text)
        expect(result[:content]).to eq(I18n.t('chat.message.fallback'))
      end
    end

    context 'when LLM returns multiple tool_calls (multi-create)' do
      before do
        allow(client).to receive(:chat).and_return({
          type:        :tool_use,
          tool_name:   'create_earning',
          tool_input:  { 'amount' => 245.0, 'platform' => 'shopee', 'date' => '2026-06-23' },
          extra_calls: [{ name: 'create_expense', input: { 'amount' => 45.0, 'category' => 'fuel', 'date' => '2026-06-23' } }]
        })
      end

      it 'returns only the first call as preview, ignoring extra_calls' do
        result = service.call

        expect(result[:type]).to eq(:preview)
        expect(result[:action]).to eq('create_earning')
        expect(result).not_to have_key(:extra_calls)
      end
    end

    context 'when LLM response includes text_before' do
      it 'includes text_before in the preview result' do
        allow(client).to receive(:chat).and_return({
          type:        :tool_use,
          tool_name:   'create_earning',
          tool_input:  { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-06-24' },
          text_before: 'E o iFood de R$ 45, registro também?'
        })

        result = service.call

        expect(result[:type]).to eq(:preview)
        expect(result[:text_before]).to eq('E o iFood de R$ 45, registro também?')
      end

      it 'omits text_before from result when nil' do
        allow(client).to receive(:chat).and_return({
          type:        :tool_use,
          tool_name:   'create_earning',
          tool_input:  { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-06-24' },
          text_before: nil
        })

        result = service.call

        expect(result).not_to have_key(:text_before)
      end
    end

    context 'when the tool_input amount comes as an Integer (Gemini-shaped) and as a Float (legacy Groq-shaped)' do
      let(:integer_input) { { 'amount' => 45, 'category' => 'fuel', 'date' => '2026-04-21' } }
      let(:float_input) { { 'amount' => 45.0, 'category' => 'fuel', 'date' => '2026-04-21' } }

      it 'produces the same preview regardless of the numeric type' do
        allow(client).to receive(:chat).and_return(
          { type: :tool_use, tool_name: 'create_expense', tool_input: integer_input },
          { type: :tool_use, tool_name: 'create_expense', tool_input: float_input }
        )

        preview_with_integer = described_class.new(messages: messages, today: Date.new(2026, 4, 21), client: client).call
        preview_with_float = described_class.new(messages: messages, today: Date.new(2026, 4, 21), client: client).call

        expect(preview_with_integer[:type]).to eq(:preview)
        expect(preview_with_integer[:summary]).to eq(preview_with_float[:summary])
        expect(preview_with_integer[:action]).to eq(preview_with_float[:action])
      end
    end

    context 'parity across the 17 query kinds' do
      Ai::Tools::Registry::QUERY_KINDS.each do |kind, expected|
        it "routes type=#{kind} to the matching reader and answer_presenter" do
          reader_double = instance_double('reader', call: :reader_output)
          presenter_double = instance_double('presenter', call: 'rendered')
          allow(expected.reader).to receive(:new).with({ 'type' => kind }, user: nil).and_return(reader_double)
          allow(expected.answer_presenter).to receive(:new).with(:reader_output).and_return(presenter_double)
          allow(client).to receive(:chat).and_return({
            type: :tool_use, tool_name: 'query', tool_input: { 'type' => kind }
          })

          result = service.call

          expect(result).to eq(type: :answer, content: 'rendered')
        end
      end
    end

    context 'when building a create preview' do
      before do
        allow(client).to receive(:chat).and_return({
          type:       :tool_use,
          tool_name:  'create_earning',
          tool_input: { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-04-21' }
        })
      end

      it 'embeds the summary in the content sent back into the LLM history' do
        result = service.call

        expect(result[:content]).to include(result[:summary])
      end
    end

    context 'when it rejects a tool with an invalid amount' do
      before do
        allow(client).to receive(:chat).and_return({
          type:       :tool_use,
          tool_name:  'create_expense',
          tool_input: { 'amount' => -1337.42, 'category' => 'fuel', 'date' => '2026-04-21' }
        })
      end

      it 'logs the tool name without leaking the amount value' do
        logged = nil
        allow(Rails.logger).to receive(:warn) { |message| logged = message }

        service.call

        expect(logged).to include('create_expense')
        expect(logged).not_to include('1337')
      end
    end
  end
end
