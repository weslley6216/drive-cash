module ChatSession
  extend ActiveSupport::Concern

  private

  HISTORY_LIMIT = 12
  private_constant :HISTORY_LIMIT

  def chat_history
    (session[:chat_history] || []).map(&:symbolize_keys)
  end

  def add_to_history(message)
    history = chat_history
    history << message.to_session_hash
    session[:chat_history] = history.last(HISTORY_LIMIT)
  end

  def clear_history
    session.delete(:chat_history)
    session.delete(:pending_tool_calls)
  end

  def pending_tool_calls
    (session[:pending_tool_calls] || []).map { |call| call.transform_keys(&:to_sym) }
  end

  def push_pending_calls(calls)
    session[:pending_tool_calls] = calls.map { |call| call.transform_keys(&:to_s) }
  end

  def pop_pending_call
    queue = pending_tool_calls
    return nil if queue.empty?

    next_call = queue.shift
    session[:pending_tool_calls] = queue.map { |call| call.transform_keys(&:to_s) }
    next_call
  end

  def pending_calls?
    pending_tool_calls.any?
  end
end
