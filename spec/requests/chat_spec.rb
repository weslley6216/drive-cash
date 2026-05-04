require 'rails_helper'

RSpec.describe 'Chats', type: :request do
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
          record: {
            amount: 300,
            category: 'maintenance',
            date: '2026-06-05',
            vendor: 'Oficina',
            installments: 3,
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
          record: {
            amount: 300,
            category: 'maintenance',
            date: '2026-06-05',
            vendor: 'Oficina',
            installments: 3,
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
               record: { amount: '', platform: 'uber', date: '2026-04-22' }
             },
             as: :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.error_prefix'))
      end
    end

    context 'when confirming with an unknown action' do
      let(:params) { { record_action: 'create_expense', record: { amount: 45, category: 'fuel', date: '2026-04-22' } } }

      it 'renders the home chip as fallback' do
        allow_any_instance_of(ChatController).to receive(:confirm).and_wrap_original do |method, *args|
          controller = method.receiver
          controller.respond_to do |format|
            format.turbo_stream do
              controller.render Chat::ConfirmView.new(success: true, message: 'Fallback', action: 'unknown_action', date: Date.new(2026, 4, 22))
            end
          end
        end

        post chat_confirm_path, params: params, as: :turbo_stream

        expect(response.body).to include(I18n.t('chat.confirm.btn_home'))
      end
    end

    context 'when confirming with an unknown action' do
      it 'returns bad request' do
        post chat_confirm_path,
             params: { record_action: 'unknown_action', record: {} },
             as: :turbo_stream

        expect(response).to have_http_status(:bad_request)
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
end
