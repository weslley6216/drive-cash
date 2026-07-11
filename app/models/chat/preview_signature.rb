module Chat
  PreviewSignature = Data.define(:action, :params) do
    def self.from(action:, params:)
      new(
        action: action.to_s,
        params: (params || {}).transform_keys(&:to_s).transform_values(&:to_s)
      )
    end

    def to_session_hash
      { 'action' => action, 'params' => params }
    end

    def matches?(other)
      action == other.action && params == other.params
    end
  end
end
