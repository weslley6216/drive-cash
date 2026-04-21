module Chat
  Message = Struct.new(:role, :content, :type, :action, :params, :summary, keyword_init: true) do
    def self.from_user(content)
      new(role: 'user', content: content.to_s)
    end

    def self.from_result(result, fallback_content:)
      new(
        role:    'assistant',
        content: (result[:content].presence || fallback_content).to_s,
        type:    result[:type],
        action:  result[:action],
        params:  result[:params],
        summary: result[:summary]
      )
    end

    def to_session_hash
      to_h.compact
    end
  end
end
