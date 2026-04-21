module Llm
  class Client
    ADAPTERS = {
      'groq'   => -> { Adapters::Groq },
      'gemini' => -> { Adapters::Gemini }
    }.freeze

    def self.chat(messages:, tools: [], system: nil)
      last_error = nil

      adapter_chain.each do |adapter_class|
        begin
          return adapter_class.new.chat(messages: messages, tools: tools, system: system)
        rescue Llm::RateLimitError, Llm::ConfigurationError, Llm::Error => e
          Rails.logger.warn "[LLM] #{adapter_class.name} failed: #{e.message}. Trying next provider."
          last_error = e
        end
      end

      raise last_error || Llm::Error.new('No LLM provider available.')
    end

    private_class_method def self.adapter_chain
      providers = [
        ENV.fetch('LLM_PROVIDER', nil),
        ENV.fetch('LLM_FALLBACK', nil)
      ].compact

      raise Llm::ConfigurationError, 'LLM_PROVIDER is not set.' if providers.empty?

      providers.map do |name|
        ADAPTERS.fetch(name) { raise Llm::ConfigurationError, "Unknown LLM provider: '#{name}'." }.call
      end
    end
  end
end
