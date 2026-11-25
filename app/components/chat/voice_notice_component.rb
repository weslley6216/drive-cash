module Chat
  class VoiceNoticeComponent < ApplicationComponent
    def view_template
      div(
        class: 'hidden absolute left-4 right-4 bottom-full mb-3 flex justify-center pointer-events-none',
        role:  'status',
        data:  {
          speech_target: 'notice',
          silence:       t('chat.voice.notice.silence'),
          denied:        t('chat.voice.notice.denied')
        }
      ) do
        div(class: 'flex items-center gap-2 bg-slate-900 text-white text-xs font-medium leading-snug px-3.5 py-2 rounded-2xl shadow-lg max-w-full') do
          render PhlexIcons::Lucide::Mic.new(class: 'w-[13px] h-[13px] text-slate-400 flex-shrink-0')
          span(class: 'text-pretty', data: { speech_target: 'noticeText' })
        end
      end
    end
  end
end
