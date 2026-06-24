module Chat
  class MessageView < ApplicationView
    include Formatting
    include Chat::BubbleMixin

    def initialize(user_text:, result:)
      @user_text = user_text
      @result = result
    end

    def view_template
      raw turbo_stream.append('chat_messages') { ai_response }
    end

    private

    def ai_response
      case @result[:type]
      when :text then text_bubble(@result[:content])
      when :answer then text_bubble(@result[:content])
      when :preview then render_preview
      else
        text_bubble(t('chat.errors.unexpected'))
      end
    end

    def render_preview
      if @result[:text_before].present?
        capture do
          text_bubble(@result[:text_before])
          preview_card(@result)
        end
      else
        preview_card(@result)
      end
    end
  end
end
