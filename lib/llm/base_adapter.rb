module Llm
  class BaseAdapter
    RATE_LIMIT_STATUSES = [429, 503].freeze

    private

    def sanitize_function_leaks(text)
      text = text.gsub(/<function[^>]*>.*?<\/function>/m, '')
      text = text.gsub(/\{["\'](?:amount|platform|category|date)["\']:\s*[^}]+\}/m, '')

      text.strip
    end

    def build_connection(url, &block)
      Faraday.new(url: url) do |f|
        f.request :json
        f.request :retry,
                  max:            3,
                  interval:       0.5,
                  backoff_factor: 2,
                  retry_statuses: [429, 500, 502, 503, 504],
                  exceptions:     Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed]
        f.response :json, parser_options: { symbolize_names: false }
        f.adapter Faraday.default_adapter
        instance_exec(f, &block) if block
      end
    end
  end
end
