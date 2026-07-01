require 'rails_helper'

RSpec.describe 'Exports', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /exports/new' do
    it 'renders the form' do
      get new_export_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('exports.cta'))
    end
  end

  describe 'GET /exports' do
    it 'lists the user exports' do
      mine = create(:export, user: current_user)
      other = create(:export, user: create(:user))

      get exports_path

      expect(response.body).to include("exports/#{mine.id}")
      expect(response.body).not_to include("exports/#{other.id}")
    end
  end

  describe 'POST /exports' do
    let(:valid_params) do
      {
        export: {
          period_kind:  'year',
          period_start: '2026-01-01',
          period_end:   '2026-12-31',
          format:       'pdf',
          includes:     { earnings: '1', expenses: '1', refuelings: '0', maintenances: '0' }
        }
      }
    end

    it 'creates an export owned by the current user' do
      expect { post exports_path, params: valid_params }.to change(current_user.exports, :count).by(1)
    end

    it 'enqueues the export job' do
      expect { post exports_path, params: valid_params }.to have_enqueued_job(ExportJob)
    end

    it 'redirects to index with a flash notice' do
      post exports_path, params: valid_params

      expect(response).to redirect_to(exports_path)
      expect(flash[:notice]).to eq(I18n.t('exports.flash.enqueued'))
    end

    it 're-renders the form when validation fails' do
      post exports_path, params: { export: { period_kind: 'custom', period_start: '2026-12-31', period_end: '2026-01-01', format: 'pdf' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('exports.cta'))
    end

    it 'persists the includes toggles as booleans' do
      post exports_path, params: valid_params

      export = current_user.exports.last
      expect(export.includes_for(:earnings)).to be true
      expect(export.includes_for(:refuelings)).to be false
    end
  end

  describe 'GET /exports/:id' do
    context 'when the export belongs to another user' do
      it 'returns not found' do
        other_export = create(:export, user: create(:user))

        get export_path(other_export)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the export is not done yet' do
      it 'redirects back with a flash alert' do
        export = create(:export, user: current_user, status: 'processing')

        get export_path(export)

        expect(response).to redirect_to(exports_path)
        expect(flash[:alert]).to eq(I18n.t('exports.flash.not_ready'))
      end
    end

    context 'when the export is done' do
      it 'redirects to the attached blob' do
        export = create(:export, user: current_user, status: 'done')
        export.file.attach(io: StringIO.new('content'), filename: 'r.csv', content_type: 'text/csv')

        get export_path(export)

        expect(response).to have_http_status(:found)
        expect(response.location).to include(export.file.filename.to_s)
      end
    end
  end

  describe 'GET /exports/preview' do
    let(:params) do
      {
        export: {
          period_kind: 'this_month',
          format:      'csv',
          includes:    { earnings: '1', expenses: '1', refuelings: '0', maintenances: '0' }
        }
      }
    end

    it 'renders the summary frame with the format-aware CTA' do
      travel_to Date.new(2026, 6, 15) do
        create(:earning, user: current_user, date: Date.new(2026, 6, 10), amount: 150)

        get preview_exports_path, params: params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('id="export-summary"')
        expect(response.body).to include(I18n.t('exports.cta_format.csv'))
        expect(response.body).to include('R$ 150,00')
      end
    end

    it 'requires authentication' do
      delete session_path

      get preview_exports_path, params: params

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'GET /exports/:id/row' do
    it 'returns the latest row markup for the user export' do
      export = create(:export, user: current_user, status: 'pending')

      get row_export_path(export)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(id="export_#{export.id}"))
      expect(response.body).to include(I18n.t('exports.flash.not_ready'))
    end

    it 'returns not found for another user export' do
      other = create(:export, user: create(:user))

      get row_export_path(other)

      expect(response).to have_http_status(:not_found)
    end
  end
end
