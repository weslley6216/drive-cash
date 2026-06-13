module Ai
  class ChatExpenseParams
    ATTRIBUTE_KEYS = %w[date amount category vendor description].freeze
    PERMITTED_KEYS = %i[date amount category vendor description installments installments_period].freeze

    def initialize(raw)
      @hash = coerce_hash(raw)
    end

    def attributes
      @hash.slice(*ATTRIBUTE_KEYS)
    end

    def installments
      @hash['installments'].to_i
    end

    def period
      @hash['installments_period'].to_s
    end

    private

    def coerce_hash(raw)
      case raw
      when ActionController::Parameters
        raw.permit(*PERMITTED_KEYS).to_h.stringify_keys
      when Hash then raw.stringify_keys.except('user_id')
      else {}
      end
    end
  end
end
