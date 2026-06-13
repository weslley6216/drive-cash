module Chat
  class Payload
    def self.permit(raw, keys)
      case raw
      when ActionController::Parameters
        raw.permit(*keys).to_h.stringify_keys
      when Hash
        raw.stringify_keys.slice(*keys.map(&:to_s))
      else
        {}
      end
    end
  end
end
