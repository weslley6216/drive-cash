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

    it 'responds at the bare path too, matching what the route declares' do
      get '/service-worker'

      expect(response).to have_http_status(:success)
    end

    it 'bypasses non-GET requests before touching respondWith or the cache' do
      get '/service-worker.js'

      expect(response.body).to include("event.request.method !== 'GET'")
    end

    it 'treats navigation requests as network-only with an offline fallback' do
      get '/service-worker.js'

      expect(response.body).to include("request.mode === 'navigate'")
      expect(response.body).to include("caches.match('/offline.html')")
    end

    it 'keeps static assets on the network-first cache path' do
      get '/service-worker.js'

      expect(response.body).to include('cache.put(event.request, responseClone)')
      expect(response.body.scan('cache.put').count).to eq(1)
    end

    it 'precaches only assets that do not require a session' do
      get '/service-worker.js'

      precache_source = response.body[/ASSETS_TO_CACHE = \[(.*?)\]/m, 1]

      expect(precache_source).to include('offline.html')
      expect(precache_source).not_to include("'/'")
    end

    it 'guards push payload parsing and points icon/badge at an existing asset' do
      get '/service-worker.js'

      expect(response.body).to include('try {')
      expect(response.body).to include("badge: '/icon-192.png'")
      expect(response.body).not_to include('icon-96.png')
    end
  end
end
