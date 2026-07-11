require 'rails_helper'

RSpec.describe 'Chats', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /chat' do
    context 'when the history is empty' do
      it 'renders the initial empty state page' do
        get chat_root_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Como posso ajudar?')
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
    context 'when persisting a confirmed expense' do
      it 'associates the expense to current_user' do
        post chat_confirm_path,
             params: { record_action: 'create_expense', record: { amount: 45, category: 'fuel', date: '2026-04-22' } },
             as:     :turbo_stream

        expect(Expense.last.user).to eq(current_user)
      end
    end

    context 'when persisting a confirmed earning' do
      it 'associates the earning to current_user' do
        post chat_confirm_path,
             params: { record_action: 'create_earning', record: { amount: 200, platform: 'uber', date: '2026-04-22' } },
             as:     :turbo_stream

        expect(Earning.last.user).to eq(current_user)
      end
    end

    context 'when confirming a valid expense' do
      let(:params) { { record_action: 'create_expense', record: { amount: 45, category: 'fuel', date: '2026-04-22' } } }

      it 'saves the expense and renders the expense chips' do
        post chat_confirm_path, params: params, as: :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.success_expense'))
        expect(response.body).to include(I18n.t('chat.confirm.btn_expenses'))
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
          post chat_confirm_path, params: params, as: :turbo_stream
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
        post chat_confirm_path, params: params, as: :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
      end
    end

    context 'when confirming a valid earning' do
      let(:params) { { record_action: 'create_earning', record: { amount: 200, platform: 'uber', date: '2026-04-22' } } }

      it 'saves the earning and renders the dashboard chips' do
        expect {
          post chat_confirm_path, params: params, as: :turbo_stream
        }.to change(Earning, :count).by(1)

        expect(response.body).to include(I18n.t('chat.confirm.success_earning'))
        expect(response.body).to include(I18n.t('chat.confirm.btn_dashboard'))
      end
    end

    context 'when the record is invalid' do
      let(:invalid_params) { { record_action: 'create_expense', record: { amount: nil } } }

      it 'returns the view with validation errors' do
        post chat_confirm_path, params: invalid_params, as: :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
      end
    end

    context 'when confirming an earning with invalid data (non-expense branch)' do
      it 'returns the view with validation errors without calling ExpenseFromChat' do
        post chat_confirm_path,
             params: {
               record_action: 'create_earning',
               record:        { amount: '', platform: 'uber', date: '2026-04-22' }
             },
             as:     :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
      end
    end

    context 'when confirming with an unknown action' do
      it 'renders a failure message via turbo stream' do
        post chat_confirm_path,
             params: { record_action: 'unknown_action', record: {} },
             as:     :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('chat.errors.unknown_action'))
      end
    end

    context 'when the payload tries to forge user_id for an expense' do
      let(:other) { create(:user) }

      it 'persists the expense owned by current_user' do
        post chat_confirm_path,
             params: { record_action: 'create_expense', record: { amount: 45, category: 'fuel', date: '2026-04-22', user_id: other.id } },
             as:     :turbo_stream

        expect(Expense.last.user).to eq(current_user)
      end
    end

    context 'when the payload tries to forge user_id for an earning' do
      let(:other) { create(:user) }

      it 'persists the earning owned by current_user' do
        post chat_confirm_path,
             params: { record_action: 'create_earning', record: { amount: 200, platform: 'uber', date: '2026-04-22', user_id: other.id } },
             as:     :turbo_stream

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
          post chat_confirm_path, params: params, as: :turbo_stream
        }.not_to change(Expense, :count)

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
        expect(response.body).to include(I18n.t('expenses.installments.errors.invalid_repeat_max'))
      end
    end
  end

  describe 'POST /chat/cancel' do
    let(:parser_mock) { instance_double(Ai::ParserService) }

    before { allow(Ai::ParserService).to receive(:new).and_return(parser_mock) }

    it 'sends the cancelled record identity into the history' do
      histories = []
      allow(parser_mock).to receive(:call).and_return(
        { type: :preview, action: 'create_earning', summary: 'Receita de R$ 80,00 via Uber em 02/07/2026',
          params: { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-07-02' } },
        { type: :text, content: 'Beleza, mais alguma coisa?' }
      )
      allow(Ai::ParserService).to receive(:new) do |messages:, **|
        histories << messages.map { |message| message[:content].to_s }
        parser_mock
      end

      post chat_message_path, params: { message: 'ganhei 80 no Uber hoje' }, as: :turbo_stream
      post chat_cancel_preview_path, params: { action_name: 'create_earning' }, as: :turbo_stream

      cancel_history = histories.last.join("\n")
      expect(cancel_history).to include('Uber')
      expect(cancel_history).to include('80,00')
    end

    it 'adds cancelled history entry and re-invokes ParserService for continuation' do
      allow(parser_mock).to receive(:call).and_return(
        { type: :preview, action: 'create_earning', summary: 'Receita de R$ 80,00 via Uber',
          params: { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-06-24' } },
        { type: :preview, action: 'create_earning', summary: 'Receita de R$ 45,00 via iFood',
          params: { 'amount' => 45, 'platform' => 'ifood', 'date' => '2026-06-24' } }
      )

      post chat_message_path, params: { message: 'Uber 80 e iFood 45 hoje' }, as: :turbo_stream

      post chat_cancel_preview_path, params: { action_name: 'create_earning' }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('iFood')
    end

    it 'renders cancelled message when depth exceeded' do
      allow(parser_mock).to receive(:call).and_return(
        { type: :preview, action: 'create_earning', summary: 'Receita',
          params: { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-06-24' } },
        { type: :text, content: 'Texto 1' },
        { type: :text, content: 'Texto 2' },
        { type: :text, content: 'Texto 3' },
        { type: :text, content: 'Texto 4' },
        { type: :text, content: 'Texto 5' }
      )

      post chat_message_path, params: { message: 'x' }, as: :turbo_stream

      ChatSession::MAX_CONTINUATION_DEPTH.times do
        post chat_cancel_preview_path, params: { action_name: 'create_earning' }, as: :turbo_stream
      end

      post chat_cancel_preview_path, params: { action_name: 'create_earning' }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('chat.history.preview_cancelled'))
    end
  end

  describe 'auto-continue after confirm' do
    let(:parser_mock) { instance_double(Ai::ParserService) }

    before { allow(Ai::ParserService).to receive(:new).and_return(parser_mock) }

    it 'renders continuation preview in ConfirmView when auto-continue returns a preview' do
      earning_input = { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-06-24' }

      allow(parser_mock).to receive(:call).and_return(
        { type: :preview, action: 'create_earning', summary: 'Receita de R$ 80,00 via Uber',
          params: earning_input },
        { type: :preview, action: 'create_earning', summary: 'Receita de R$ 45,00 via iFood',
          params: { 'amount' => 45, 'platform' => 'ifood', 'date' => '2026-06-24' } }
      )

      post chat_message_path, params: { message: 'Uber 80 e iFood 45 hoje' }, as: :turbo_stream
      nonce = response.body.match(/name="confirm_nonce" value="([^"]+)"/)&.[](1)

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: earning_input, confirm_nonce: nonce },
           as:     :turbo_stream

      expect(response.body).to include('iFood')
      expect(response.body).to include('45')
    end

    it 'renders text continuation when auto-continue returns plain text' do
      allow(parser_mock).to receive(:call).and_return(
        { type: :preview, action: 'create_earning', summary: 'Receita de R$ 80,00 via Uber',
          params: { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-06-24' } },
        { type: :text, content: 'Ótimo! Mais alguma coisa para registrar?' }
      )

      post chat_message_path, params: { message: 'Uber 80 hoje' }, as: :turbo_stream
      nonce = response.body.match(/name="confirm_nonce" value="([^"]+)"/)&.[](1)

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: { amount: 80, platform: 'uber', date: '2026-06-24' }, confirm_nonce: nonce },
           as:     :turbo_stream

      expect(response.body).to include('Mais alguma coisa')
    end

    it 'renders text_before bubble when auto-continue preview includes text_before' do
      allow(parser_mock).to receive(:call).and_return(
        { type: :preview, action: 'create_earning', summary: 'Receita de R$ 80,00 via Uber',
          params: { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-06-24' } },
        { type:        :preview,
          action:      'create_earning',
          summary:     'Receita de R$ 45,00 via iFood',
          text_before: 'Ótimo! E o iFood de R$ 45, registro também?',
          params:      { 'amount' => 45, 'platform' => 'ifood', 'date' => '2026-06-24' } }
      )

      post chat_message_path, params: { message: 'Uber 80 e iFood 45 hoje' }, as: :turbo_stream
      nonce = response.body.match(/name="confirm_nonce" value="([^"]+)"/)&.[](1)

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: { amount: 80, platform: 'uber', date: '2026-06-24' }, confirm_nonce: nonce },
           as:     :turbo_stream

      expect(response.body).to include('Ótimo! E o iFood de R$ 45')
    end

    it 'stops auto-continue after reaching max depth' do
      earning_input = { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-06-24' }
      preview_result = { type: :preview, action: 'create_earning', summary: 'Receita de R$ 80,00 via Uber', params: earning_input }

      allow(parser_mock).to receive(:call).and_return(preview_result)

      post chat_message_path, params: { message: 'x' }, as: :turbo_stream
      nonce = response.body.match(/name="confirm_nonce" value="([^"]+)"/)&.[](1)

      ChatSession::MAX_CONTINUATION_DEPTH.times do
        post chat_confirm_path,
             params: { record_action: 'create_earning', record: earning_input, confirm_nonce: nonce },
             as:     :turbo_stream
        nonce = response.body.match(/name="confirm_nonce" value="([^"]+)"/)&.[](1)
      end

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: earning_input, confirm_nonce: nonce },
           as:     :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('chat.confirm.success_earning'))
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
  end

  describe 'conversational multi-create — LLM history contract' do
    let(:responses) do
      [
        { type: :tool_use, tool_name: 'create_earning', tool_input: { 'amount' => 80, 'platform' => 'uber', 'date' => '2026-07-02' } },
        { type: :tool_use, tool_name: 'create_earning', tool_input: { 'amount' => 45, 'platform' => 'ifood', 'date' => '2026-07-02' } },
        { type: :text, content: 'Fechou, chefe!' }
      ]
    end
    let(:sent_histories) { [] }

    before do
      allow(Llm::Client).to receive(:chat) do |messages:, **|
        sent_histories << messages.map { |message| message[:content].to_s }
        responses.shift
      end
    end

    it 'identifies the confirmed record in the history sent on auto-continue' do
      post chat_message_path, params: { message: 'ganhei 80 no Uber e 45 no iFood hoje' }, as: :turbo_stream
      nonce = response.body.match(/name="confirm_nonce" value="([^"]+)"/)&.[](1)

      post chat_confirm_path,
           params: { record_action: 'create_earning', record: { amount: 80, platform: 'uber', date: '2026-07-02' }, confirm_nonce: nonce },
           as:     :turbo_stream

      auto_continue_history = sent_histories.last.join("\n")

      expect(auto_continue_history).to include(
        I18n.t('chat.history.record_confirmed', summary: 'Receita de R$ 80,00 via Uber em 02/07/2026')
      )
    end
  end
end
