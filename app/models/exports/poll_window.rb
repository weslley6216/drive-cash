module Exports
  class PollWindow
    INTERVAL_MS = 4_000

    attr_reader :interval_ms

    def initialize(stale_after: Export::STALE_AFTER, interval_ms: INTERVAL_MS)
      @stale_after = stale_after
      @interval_ms = interval_ms
    end

    def max_attempts
      @stale_after.in_milliseconds.fdiv(@interval_ms).ceil + 1
    end
  end
end
