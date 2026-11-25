module Chat
  Message = Data.define(:role, :content, :type, :action, :params, :summary, :voice) do
    def self.from_user(content, voice: false)
      new(role: 'user', content: content.to_s, type: nil, action: nil, params: nil, summary: nil, voice: voice || nil)
    end

    def self.from_result(result, fallback_content:)
      new(
        role:    'assistant',
        content: (result[:content].presence || fallback_content).to_s,
        type:    result[:type],
        action:  result[:action],
        params:  result[:params],
        summary: result[:summary],
        voice:   nil
      )
    end

    def to_session_hash
      to_h.compact
    end
  end
end
