module Llm
  class Error < StandardError; end
  class RateLimitError < Error; end
  class ConfigurationError < Error; end
end
