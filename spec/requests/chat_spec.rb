require 'rails_helper'

RSpec.describe 'Chats', type: :request do
  let(:current_user) { create(:user) }
  let(:summary_answer) do
    {
      type:    :answer,
      content: 'profit: 1240.0, earnings: 1680.0, expenses: 440.0',
      card:    {
        kind: 'summary', year: 2026, month: 11, profit: 1240.0, earnings: 1680.0, expenses: 440.0,
        profit_change: 12.0, best_day_on: '2026-11-12', best_day_amount: 320.0
      }
    }
  end

  before { login_as(current_user) }

  describe 'GET /chat' do
    context 'when the history is empty' do
      it 'renders the initial empty state page' do
        get chat_root_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Como posso ajudar?')
        expect(response.body).to include('Pergunte ou registre…')
      end

      it 'offers the ready-made questions above the message box' do
        get chat_root_path

        expect(response.body).to include('data-chat-question-param="Lucro do mês"')
        expect(response.body).to include('data-chat-question-param="Gastei com combustível?"')
        expect(response.body).to include('data-chat-question-param="Melhor dia"')
      end
    end

    context 'when a message was spoken' do
      let(:parser_mock) { instance_double(Ai::ParserService) }

      before do
        allow(Ai::ParserService).to receive(:new).and_return(parser_mock)
        allow(parser_mock).to receive(:call).and_return({ type: :text, content: 'Anotado' })
      end

      it 'keeps the microphone on the spoken bubble after a reload' do
        post chat_message_path, params: { message: 'abasteci 80', voice: '1' }, as: :turbo_stream

        get chat_root_path

        expect(response.body).to include('abasteci 80')
        expect(response.body.scan('text-white/80').size).to eq(2)
      end

      it 'shows a typed bubble without the microphone' do
        post chat_message_path, params: { message: 'abasteci 80' }, as: :turbo_stream

        get chat_root_path

        expect(response.body).to include('abasteci 80')
        expect(response.body.scan('text-white/80').size).to eq(1)
      end
    end

    context 'when there is conversation history' do
      let(:parser_mock) { instance_double(Ai::ParserService) }

      before do
        allow(Ai::ParserService).to receive(:new).and_return(parser_mock)
      end

      it 'renders the page with all previous messages as plain text' do
        allow(parser_mock).to receive(:call).and_return({ type: :text, content: 'I am an AI' })
        post chat_message_path, params: { message: 'Hello' }, as: :turbo_stream

        allow(parser_mock).to receive(:call).and_return({
          type: :preview, action: 'create_expense',
          content: I18n.t('chat.history.preview_sent'),
          summary: 'Despesa de R$ 50,00 em 22/04/2026',
          params: { 'amount' => 50, 'category' => 'meals', 'date' => '2026-04-23' }
        })
        post chat_message_path, params: { message: 'Spent 50' }, as: :turbo_stream

        allow(parser_mock).to receive(:call).and_return({
          type: :preview, action: 'create_earning',
          content: I18n.t('chat.history.preview_sent'),
          summary: 'Receita de R$ 100,00',
          params: { 'amount' => 100, 'platform' => 'uber', 'date' => '2026-04-23' }
        })
        post chat_message_path, params: { message: 'Got 100' }, as: :turbo_stream

        get chat_root_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Hello')
        expect(response.body).to include('Spent 50')
        expect(response.body).to include('Got 100')
        expect(response.body).to include('I am an AI')
        expect(response.body).to include('Despesa de R$ 50,00 em 22/04/2026')
        expect(response.body).to include('Receita de R$ 100,00')
        expect(response.body).not_to include(I18n.t('chat.history.preview_sent'))
        expect(response.body).not_to include('Entendi o seguinte')
        expect(response.body).not_to include('Confirmar')
      end

      it 'redraws an answer card from the session history' do
        allow(parser_mock).to receive(:call).and_return(summary_answer)
        post chat_message_path, params: { message: 'Lucro do mês' }, as: :turbo_stream

        get chat_root_path

        expect(response.body).to include('Lucro do mês')
        expect(response.body).to include("−R$\u00A0440,00").and include('Qui, 12/11')
        expect(response.body).not_to include('profit: 1240.0')
      end
    end
  end

  describe 'POST /chat/message' do
    let(:parser_mock) { instance_double(Ai::ParserService) }

    before do
      allow(Ai::ParserService).to receive(:new).and_return(parser_mock)
    end

    context 'when ParserService returns an answer (query tool)' do
      before do
        allow(parser_mock).to receive(:call).and_return({ type: :answer, content: 'Lucro: R$ 500,00' })
      end

      it 'renders the answer as a text bubble' do
        post chat_message_path, params: { message: 'qual meu lucro?' }, as: :turbo_stream

        expect(response.body).to include('500,00')
      end
    end

    context 'when ParserService returns an answer with a summary card' do
      before do
        allow(parser_mock).to receive(:call).and_return(summary_answer)
      end

      it 'renders the card inside the Caju bubble instead of the raw numbers' do
        post chat_message_path, params: { message: 'Lucro do mês' }, as: :turbo_stream

        expect(response.body).to include('px-4 py-3 rounded-2xl rounded-tl-sm max-w-[82%]')
        expect(response.body).to include("+R$\u00A01.680,00").and include('Qui, 12/11')
        expect(response.body).not_to include('profit: 1240.0')
      end
    end

    context 'when ParserService returns an answer whose card has no component' do
      before do
        allow(parser_mock).to receive(:call).and_return({
          type: :answer, content: 'Melhor dia: 12/11 com R$ 320,00', card: { kind: 'best_day', amount: 320.0 }
        })
      end

      it 'falls back to the text bubble' do
        post chat_message_path, params: { message: 'Melhor dia' }, as: :turbo_stream

        expect(response.body).to include('Melhor dia: 12/11 com R$ 320,00')
      end
    end

    context 'when ParserService returns an expense preview' do
      before do
        allow(parser_mock).to receive(:call).and_return({
          type: :preview, action: 'create_expense', summary: 'Despesa de R$ 50,00 em 22/04/2026',
          params: { 'amount' => 50, 'category' => 'meals', 'date' => '2026-04-22' }
        })
      end

      it 'adds to history and renders the preview card' do
        post chat_message_path, params: { message: 'Spent 50' }, as: :turbo_stream

        expect(response.body).to include('50,00')
        expect(response.body).to include('22/04/2026')
        expect(response.body).to include('Entendi o seguinte')
      end
    end

    context 'when ParserService returns an earning preview' do
      before do
        allow(parser_mock).to receive(:call).and_return({
          type: :preview, action: 'create_earning', summary: 'Receita de R$ 100,00 via Uber em 22/04/2026',
          params: { 'amount' => 100, 'platform' => 'uber', 'date' => '2026-04-22' }
        })
      end

      it 'renders the earning preview correctly' do
        post chat_message_path, params: { message: 'Got 100' }, as: :turbo_stream

        expect(response.body).to include('100,00')
        expect(response.body).to include('Uber')
      end
    end

    context 'when ParserService returns a preview with an invalid date' do
      before do
        allow(parser_mock).to receive(:call).and_return({
          type: :preview, action: 'create_earning', summary: 'Receita em not-a-date',
          params: { 'amount' => 100, 'platform' => 'uber', 'date' => 'not-a-date' }
        })
      end

      it 'falls back to rendering the raw date string' do
        post chat_message_path, params: { message: 'Got 100' }, as: :turbo_stream

        expect(response.body).to include('not-a-date')
      end
    end

    context 'when ParserService returns a preview with text_before' do
      before do
        allow(parser_mock).to receive(:call).and_return({
          type:        :preview,
          action:      'create_earning',
          summary:     'Receita de R$ 45,00 via iFood em 24/06/2026',
          text_before: 'Já registrei o Uber! E o iFood de R$ 45, registro também?',
          params:      { 'amount' => 45, 'platform' => 'ifood', 'date' => '2026-06-24' }
        })
      end

      it 'renders text_before as a separate bubble before the preview card' do
        post chat_message_path, params: { message: 'Uber 80 e iFood 45 hoje' }, as: :turbo_stream

        expect(response.body).to include('Já registrei o Uber!')
        expect(response.body).to include('Receita de R$ 45,00 via iFood')
      end
    end

    context 'when ParserService returns an unexpected type' do
      before do
        allow(parser_mock).to receive(:call).and_return({ type: :alien })
      end

      it 'falls back to the safety error message' do
        post chat_message_path, params: { message: 'Hi' }, as: :turbo_stream

        expect(response.body).to include(I18n.t('chat.errors.unexpected'))
      end
    end

    context 'when ParserService returns a preview with an unknown action' do
      before do
        allow(parser_mock).to receive(:call).and_return({
          type: :preview, action: 'unknown_action', summary: I18n.t('chat.message.fallback')
        })
      end

      it 'falls back to the action fallback message' do
        post chat_message_path, params: { message: 'Do something weird' }, as: :turbo_stream

        expect(response.body).to include(I18n.t('chat.message.fallback'))
      end
    end
  end

  describe 'POST /chat/confirm' do
    let(:parser_mock) { instance_double(Ai::ParserService) }

    before do
      allow(Ai::ParserService).to receive(:new).and_return(parser_mock)
      allow(parser_mock).to receive(:call).and_return({
        type:    :preview,
        action:  'create_expense',
        summary: 'Despesa de R$ 45,00 em 22/04/2026',
        params:  { 'amount' => 45, 'category' => 'fuel', 'date' => '2026-04-22' }
      })
    end

    context 'when persisting a confirmed expense' do
      it 'associates the expense to current_user' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path,
             params: { record_action: 'create_expense', record: { amount: 45, category: 'fuel', date: '2026-04-22' },
                       confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

        expect(Expense.last.user).to eq(current_user)
      end
    end

    context 'when persisting a confirmed earning' do
      it 'associates the earning to current_user' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path,
             params: { record_action: 'create_earning', record: { amount: 200, platform: 'uber', date: '2026-04-22' },
                       confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

        expect(Earning.last.user).to eq(current_user)
      end
    end

    context 'when confirming a valid expense' do
      let(:params) { { record_action: 'create_expense', record: { amount: 45, category: 'fuel', date: '2026-04-22' } } }

      it 'saves the expense and renders the expense chips' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path, params: params.merge(confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1]),
                                as:     :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.success_expense'))
        expect(response.body).to include(I18n.t('chat.confirm.btn_expenses'))
      end
    end

    context 'when the confirmed record carries a key outside the tool whitelist' do
      it 'persists the record and ignores the unexpected key' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path,
             params: { record_action: 'create_expense', record: { amount: 45, category: 'fuel', date: '2026-04-22', installment_count: 99 },
                       confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

        expect(Expense.last).to be_present
        expect(Expense.last.installment_count).to be_nil
      end
    end

    context 'when confirming an installment expense' do
      let(:params) do
        {
          record_action: 'create_expense',
          record:        {
            amount:              300,
            category:            'maintenance',
            date:                '2026-06-05',
            vendor:              'Oficina',
            installments:        3,
            installments_period: 'monthly'
          }
        }
      end

      it 'persists installments and renders success chips' do
        expect {
          post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

          post chat_confirm_path, params: params.merge(confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1]),
                                  as:     :turbo_stream
        }.to change(Expense, :count).by(3)

        expect(response.body).to include(I18n.t('chat.confirm.success_expense'))
        expect(response.body).to include(I18n.t('chat.confirm.btn_expenses'))
      end
    end

    context 'when installment confirmation is incomplete' do
      let(:params) do
        {
          record_action: 'create_expense',
          record:        {
            amount:              300,
            category:            'maintenance',
            date:                '2026-06-05',
            vendor:              'Oficina',
            installments:        3,
            installments_period: ''
          }
        }
      end

      it 'returns an error turbo message' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path, params: params.merge(confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1]),
                                as:     :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
      end
    end

    context 'when confirming a valid earning' do
      let(:params) { { record_action: 'create_earning', record: { amount: 200, platform: 'uber', date: '2026-04-22' } } }

      it 'saves the earning and renders the dashboard chips' do
        expect {
          post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

          post chat_confirm_path, params: params.merge(confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1]),
                                  as:     :turbo_stream
        }.to change(Earning, :count).by(1)

        expect(response.body).to include(I18n.t('chat.confirm.success_earning'))
        expect(response.body).to include(I18n.t('chat.confirm.btn_dashboard'))
      end
    end

    context 'when the record is invalid' do
      let(:invalid_params) { { record_action: 'create_expense', record: { amount: nil } } }

      it 'returns the view with validation errors' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path, params: invalid_params.merge(confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1]),
                                as:     :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
      end
    end

    context 'when confirming an earning with invalid data (non-expense branch)' do
      it 'returns the view with validation errors without calling ExpenseFromChat' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path, params: {
          record_action: 'create_earning',
          record:        { amount: '', platform: 'uber', date: '2026-04-22' },
          confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1]
        }, as: :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
      end
    end

    context 'when confirming with an unknown action' do
      it 'renders a failure message via turbo stream' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path,
             params: { record_action: 'unknown_action', record: {},
                       confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('chat.errors.unknown_action'))
      end
    end

    context 'when the payload tries to forge user_id for an expense' do
      let(:other) { create(:user) }

      it 'persists the expense owned by current_user' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path,
             params: { record_action: 'create_expense', record: { amount: 45, category: 'fuel', date: '2026-04-22', user_id: other.id },
                       confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

        expect(Expense.last.user).to eq(current_user)
      end
    end

    context 'when the payload tries to forge user_id for an earning' do
      let(:other) { create(:user) }

      it 'persists the earning owned by current_user' do
        post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

        post chat_confirm_path,
             params: { record_action: 'create_earning', record: { amount: 200, platform: 'uber', date: '2026-04-22', user_id: other.id },
                       confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

        expect(Earning.last.user).to eq(current_user)
      end
    end

    context 'when installments exceed the maximum' do
      let(:params) do
        {
          record_action: 'create_expense',
          record:        {
            amount:              300,
            category:            'maintenance',
            date:                '2026-06-05',
            vendor:              'Oficina',
            installments:        Expense::MAX_INSTALLMENTS + 1,
            installments_period: 'monthly'
          }
        }
      end

      it 'does not persist any expense and renders the error' do
        expect {
          post chat_message_path, params: { message: 'registra pra mim' }, as: :turbo_stream

          post chat_confirm_path, params: params.merge(confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1]),
                                  as:     :turbo_stream
        }.not_to change(Expense, :count)

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
        expect(response.body).to include(I18n.t('expenses.installments.errors.invalid_repeat_max'))
      end
    end
  end

  describe 'preview queue' do
    let(:shopee_input) { { 'amount' => 120, 'platform' => 'shopee', 'date' => '2026-11-16' } }
    let(:ipiranga_input) { { 'amount' => 60, 'category' => 'fuel', 'vendor' => 'Ipiranga', 'date' => '2026-11-16' } }
    let(:uber_input) { { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-11-16' } }
    let(:batch_message) { 'rota de R$ 120 pelo Shopee, abasteci R$ 60 no Ipiranga e fiz R$ 80 no Uber hoje' }
    let(:batch_response) do
      {
        type:        :tool_use,
        tool_name:   'create_earning',
        tool_input:  shopee_input,
        extra_calls: [{ name: 'create_expense', input: ipiranga_input }, { name: 'create_earning', input: uber_input }]
      }
    end

    before { allow(Llm::Client).to receive(:chat).and_return(batch_response) }

    it 'presents the next item on confirm without a new LLM call' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: shopee_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream

      expect(response.body).to include(I18n.t('chat.confirm.success_earning'))
      expect(response.body).to include('Ipiranga')
      expect(Llm::Client).to have_received(:chat).once
    end

    it 'shows the validation error and still presents the next item when a queued confirm fails' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: shopee_input.merge('amount' => ''),
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream

      expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
      expect(response.body).to include('Ipiranga')
    end

    it 'closes a confirmed batch with the finished text and never repeats an item' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      post chat_confirm_path,
           params: { record_action: 'create_earning', record: shopee_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream
      post chat_confirm_path,
           params: { record_action: 'create_expense', record: ipiranga_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream
      after_second_confirm = response.body

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: uber_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream

      expect(after_second_confirm).to include('Uber')
      expect(after_second_confirm).not_to include('Ipiranga')
      expect(I18n.t('chat.history.queue_finished').any? { |phrase| response.body.include?(phrase) }).to be(true)
      expect(Llm::Client).to have_received(:chat).once
    end

    it 'ends a single-item confirm with only the success message' do
      allow(Llm::Client).to receive(:chat).and_return({ type: :tool_use, tool_name: 'create_earning', tool_input: uber_input })
      post chat_message_path, params: { message: 'fiz R$ 80 no Uber hoje' }, as: :turbo_stream

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: uber_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream

      expect(response.body).to include(I18n.t('chat.confirm.success_earning'))
      expect(I18n.t('chat.history.queue_finished').any? { |phrase| response.body.include?(phrase) }).to be(false)
      expect(Llm::Client).to have_received(:chat).once
    end

    it 'rejects the confirm of a card discarded by a new message' do
      allow(Llm::Client).to receive(:chat).and_return(batch_response, { type: :text, content: 'Beleza, me conta de novo.' })
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      discarded_nonce = response.body[/name="confirm_nonce" value="([^"]+)"/, 1]
      post chat_message_path, params: { message: 'pera, errei os valores' }, as: :turbo_stream

      expect {
        post chat_confirm_path,
             params: { record_action: 'create_earning', record: shopee_input, confirm_nonce: discarded_nonce },
             as:     :turbo_stream
      }.not_to change(Earning, :count)

      expect(response.body).to include(I18n.t('chat.confirm.duplicate_submit'))
    end

    it 'presents only the new message items after the queue is discarded' do
      allow(Llm::Client).to receive(:chat).and_return(
        batch_response,
        { type: :tool_use, tool_name: 'create_earning', tool_input: uber_input }
      )
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      post chat_message_path, params: { message: 'esquece, só o Uber de R$ 80' }, as: :turbo_stream

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: uber_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream

      expect(response.body).to include(I18n.t('chat.confirm.success_earning'))
      expect(response.body).not_to include('Ipiranga')
      expect(Llm::Client).to have_received(:chat).twice
    end

    it 'presents the next item on cancel without a new LLM call' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream

      post chat_cancel_preview_path, params: { confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

      expect(response.body).to include('Ipiranga')
      expect(Llm::Client).to have_received(:chat).once
    end

    it 'never presents a handled item again across confirm and cancel' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      post chat_confirm_path,
           params: { record_action: 'create_earning', record: shopee_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream
      post chat_cancel_preview_path, params: { confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream
      after_cancel = response.body

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: uber_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream

      expect(after_cancel).to include('Uber')
      expect(after_cancel).not_to include('Ipiranga')
      expect(I18n.t('chat.history.queue_finished').any? { |phrase| response.body.include?(phrase) }).to be(true)
      expect(Llm::Client).to have_received(:chat).once
    end

    it 'answers a single-item cancel with the cancelled message' do
      allow(Llm::Client).to receive(:chat).and_return({ type: :tool_use, tool_name: 'create_earning', tool_input: uber_input })
      post chat_message_path, params: { message: 'fiz R$ 80 no Uber hoje' }, as: :turbo_stream

      post chat_cancel_preview_path, params: { confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

      expect(response.body).to include(I18n.t('chat.history.preview_cancelled'))
      expect(I18n.t('chat.history.queue_finished').any? { |phrase| response.body.include?(phrase) }).to be(false)
      expect(Llm::Client).to have_received(:chat).once
    end

    it 'ignores a repeated cancel after the auto-continuation and keeps the next item pending' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      first_nonce = response.body[/name="confirm_nonce" value="([^"]+)"/, 1]
      post chat_cancel_preview_path, params: { confirm_nonce: first_nonce }, as: :turbo_stream
      history_after_cancel = session[:chat_history]
      queue_after_cancel = session[:preview_queue]

      post chat_cancel_preview_path, params: { confirm_nonce: first_nonce }, as: :turbo_stream

      expect(response.body).to include(I18n.t('chat.confirm.duplicate_submit'))
      expect(session[:chat_history]).to eq(history_after_cancel)
      expect(session[:preview_queue]).to eq(queue_after_cancel)
    end

    it 'ignores a cancel of a card that was already confirmed' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      shopee_nonce = response.body[/name="confirm_nonce" value="([^"]+)"/, 1]
      post chat_confirm_path,
           params: { record_action: 'create_earning', record: shopee_input, confirm_nonce: shopee_nonce },
           as:     :turbo_stream
      history_after_confirm = session[:chat_history]
      queue_after_confirm = session[:preview_queue]

      post chat_cancel_preview_path, params: { confirm_nonce: shopee_nonce }, as: :turbo_stream

      expect(response.body).to include(I18n.t('chat.confirm.duplicate_submit'))
      expect(session[:chat_history]).to eq(history_after_confirm)
      expect(session[:preview_queue]).to eq(queue_after_confirm)
    end

    it 'ignores a confirm of a card that was already cancelled' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      shopee_nonce = response.body[/name="confirm_nonce" value="([^"]+)"/, 1]
      post chat_cancel_preview_path, params: { confirm_nonce: shopee_nonce }, as: :turbo_stream

      expect {
        post chat_confirm_path,
             params: { record_action: 'create_earning', record: shopee_input, confirm_nonce: shopee_nonce },
             as:     :turbo_stream
      }.not_to change(Earning, :count)

      expect(response.body).to include(I18n.t('chat.confirm.duplicate_submit'))
    end

    it 'rejects a cancel without a nonce and keeps the card pending' do
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      queue_before_cancel = session[:preview_queue]

      post chat_cancel_preview_path, as: :turbo_stream

      expect(response.body).to include(I18n.t('chat.confirm.duplicate_submit'))
      expect(session[:preview_queue]).to eq(queue_before_cancel)
    end

    it 'rejects the cancel of a card discarded by a new message' do
      allow(Llm::Client).to receive(:chat).and_return(batch_response, { type: :text, content: 'Beleza, me conta de novo.' })
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      discarded_nonce = response.body[/name="confirm_nonce" value="([^"]+)"/, 1]
      post chat_message_path, params: { message: 'pera, errei os valores' }, as: :turbo_stream

      post chat_cancel_preview_path, params: { confirm_nonce: discarded_nonce }, as: :turbo_stream

      expect(response.body).to include(I18n.t('chat.confirm.duplicate_submit'))
      expect(response.body).not_to include('Ipiranga')
      expect(Llm::Client).to have_received(:chat).twice
    end

    it 'hands the handled items to the LLM on the next user message' do
      sent_histories = []
      allow(Llm::Client).to receive(:chat) do |messages:, **|
        sent_histories << messages.map { |message| message[:content].to_s }
        sent_histories.one? ? batch_response : { type: :text, content: 'Show, valeu!' }
      end
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream
      post chat_confirm_path,
           params: { record_action: 'create_earning', record: shopee_input,
                     confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] },
           as:     :turbo_stream
      post chat_cancel_preview_path, params: { confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

      post chat_message_path, params: { message: 'valeu' }, as: :turbo_stream

      history = sent_histories.last.join("\n")
      expect(history).to include(
        I18n.t('chat.history.record_confirmed', summary: Chat::Summaries::Earning.new(shopee_input).call)
      )
      expect(history).to include(
        I18n.t('chat.history.record_cancelled', summary: Chat::Summaries::Expense.new(ipiranga_input.merge('vendor' => 'Posto Ipiranga')).call)
      )
    end

    it 'queues every record of a single create_records call' do
      allow(Llm::Client).to receive(:chat).and_return({
        type:       :tool_use,
        tool_name:  'create_records',
        tool_input: { 'records' => [
          shopee_input.merge('action' => 'create_earning'),
          ipiranga_input.merge('action' => 'create_expense')
        ] }
      })
      post chat_message_path, params: { message: batch_message }, as: :turbo_stream

      post chat_cancel_preview_path, params: { confirm_nonce: response.body[/name="confirm_nonce" value="([^"]+)"/, 1] }, as: :turbo_stream

      expect(response.body).to include('Ipiranga')
      expect(Llm::Client).to have_received(:chat).once
    end
  end

  describe 'global loading overlay suppression' do
    it 'marks the message form so the global overlay is skipped on submit' do
      get chat_root_path

      expect(response.body).to include('data-loading-skip')
    end

    context 'when a preview card is rendered' do
      let(:parser_mock) { instance_double(Ai::ParserService) }

      before do
        allow(Ai::ParserService).to receive(:new).and_return(parser_mock)
        allow(parser_mock).to receive(:call).and_return({
          type:    :preview,
          action:  'create_expense',
          summary: 'Despesa de R$ 50,00 em 22/04/2026',
          params:  { 'amount' => 50, 'category' => 'meals', 'date' => '2026-04-22' }
        })
      end

      it 'marks the confirm form so the global overlay is skipped on submit' do
        post chat_message_path, params: { message: 'Spent 50' }, as: :turbo_stream

        expect(response.body).to include('data-loading-skip')
      end
    end
  end

  describe 'DELETE /chat/clear' do
    it 'clears the session and redirects to chat root' do
      delete chat_clear_path

      expect(session[:chat_history]).to be_nil
      expect(response).to redirect_to(chat_root_path)
    end

    it 'drops the pending preview queue' do
      allow(Llm::Client).to receive(:chat).and_return({
        type:        :tool_use,
        tool_name:   'create_earning',
        tool_input:  { 'amount' => 120, 'platform' => 'shopee', 'date' => '2026-11-16' },
        extra_calls: [{ name: 'create_earning', input: { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-11-16' } }]
      })
      post chat_message_path, params: { message: 'Shopee 120 e Uber 80 hoje' }, as: :turbo_stream
      expect(session[:preview_queue]).to be_present

      delete chat_clear_path

      expect(session[:preview_queue]).to be_nil
    end
  end

  describe 'double-submit idempotency' do
    let(:parser_mock) { instance_double(Ai::ParserService) }
    let(:earning_input) { { 'amount' => '80', 'platform' => 'uber', 'date' => '2026-06-25' } }

    before do
      allow(Ai::ParserService).to receive(:new).and_return(parser_mock)
      allow(parser_mock).to receive(:call).and_return(
        { type: :preview, action: 'create_earning', summary: 'Receita de R$ 80,00 via Uber',
          params: earning_input },
        { type: :text, content: 'Posso ajudar com mais alguma coisa?' }
      )
    end

    it 'includes a confirm_nonce hidden field in the preview card' do
      post chat_message_path, params: { message: 'ganhei 80 no Uber' }, as: :turbo_stream

      expect(response.body).to include('confirm_nonce')
    end

    it 'rejects a second confirm submitted with the same nonce' do
      post chat_message_path, params: { message: 'ganhei 80 no Uber' }, as: :turbo_stream

      nonce = response.body.match(/name="confirm_nonce" value="([^"]+)"/)&.[](1)
      expect(nonce).to be_present

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: earning_input, confirm_nonce: nonce },
           as:     :turbo_stream

      expect {
        post chat_confirm_path,
             params: { record_action: 'create_earning', record: earning_input, confirm_nonce: nonce },
             as:     :turbo_stream
      }.not_to change(Earning, :count)

      expect(response.body).to include(I18n.t('chat.confirm.duplicate_submit'))
    end

    it 'rejects a confirm without a nonce' do
      post chat_message_path, params: { message: 'ganhei 80 no Uber' }, as: :turbo_stream

      expect {
        post chat_confirm_path,
             params: { record_action: 'create_earning', record: earning_input },
             as:     :turbo_stream
      }.not_to change(Earning, :count)

      expect(response.body).to include(I18n.t('chat.confirm.duplicate_submit'))
    end
  end
end
