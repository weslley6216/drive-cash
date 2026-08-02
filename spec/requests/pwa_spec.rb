require 'rails_helper'

RSpec.describe 'PWA', type: :request do
  describe 'GET /manifest.json' do
    it 'responds without authentication' do
      get '/manifest.json'

      expect(response).to have_http_status(:success)
    end

    it 'declares standalone display so the installed app opens outside the browser' do
      get '/manifest.json'

      expect(response.parsed_body['display']).to eq('standalone')
    end

    it 'offers the sizes required for installability' do
      get '/manifest.json'

      sizes = response.parsed_body['icons'].map { |icon| icon['sizes'] }

      expect(sizes).to include('192x192', '512x512')
    end

    it 'references only icons present in public' do
      get '/manifest.json'

      sources = response.parsed_body['icons'].map { |icon| icon['src'] }
      missing = sources.reject { |src| Rails.public_path.join(src.delete_prefix('/')).exist? }

      expect(missing).to be_empty
    end
  end

  describe 'GET /service-worker.js' do
    it 'responds without authentication' do
      get '/service-worker.js'

      expect(response).to have_http_status(:success)
    end
  end
end
