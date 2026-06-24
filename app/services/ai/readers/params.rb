module Ai
  module Readers
    module Params
      def safe_year(raw)
        (raw&.to_i || Date.current.year).clamp(2000, Date.current.year + 1)
      end

      def safe_month(raw)
        return nil if raw.nil?
        raw.to_i.clamp(1, 12)
      end
    end
  end
end
