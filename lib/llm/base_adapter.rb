module Llm
  class BaseAdapter
    RATE_LIMIT_STATUSES = [429, 503].freeze
    NETWORK_ERRORS = [Faraday::ConnectionFailed, Faraday::TimeoutError].freeze

    private

    def send_request(connection, path, payload)
      connection.post(path, payload)
    rescue *NETWORK_ERRORS => e
      raise Llm::Error, "#{e.class.name}: #{e.message}"
    end

    def sanitize_function_leaks(text)
      text = text.gsub(/<function[^>]*>.*?<\/function>/m, '')
      text = text.gsub(/\{["\'](?:amount|platform|category|date)["\']:\s*[^}]+\}/m, '')

      text.strip
    end

    def build_connection(url, &block)
      Faraday.new(url: url) do |f|
        f.request :json
        f.response :json, parser_options: { symbolize_names: false }
        f.adapter Faraday.default_adapter
        instance_exec(f, &block) if block
      end
    end
  end
end
