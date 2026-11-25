module Chat
  class VoicePanelComponent < ApplicationComponent
    WAVE_BARS = 40

    def view_template
      backdrop
      sheet
    end

    private

    def backdrop
      div(
        class: 'fixed inset-0 z-30 bg-slate-900/[.28] backdrop-blur-[3px] transition-opacity duration-200 ' \
               'motion-reduce:transition-none opacity-0 pointer-events-none',
        data:  { speech_target: 'backdrop', action: 'click->speech#cancel' }
      )
    end

    def sheet
      div(
        class: 'fixed bottom-0 left-0 right-0 z-40 flex justify-center lg:px-8 invisible translate-y-[105%] ' \
               'transition-transform duration-[380ms] ease-[cubic-bezier(.2,.9,.25,1)] motion-reduce:transition-none ' \
               'motion-reduce:duration-0',
        data:  { speech_target: 'sheet' }
      ) do
        div(class: 'w-full max-w-2xl') { panel }
      end
    end

    def panel
      div(
        class:    'bg-white rounded-t-[28px] shadow-[0_-12px_40px_-12px_rgba(76,29,149,.35)] px-5 pt-3 pb-8 lg:pb-6',
        role:     'dialog',
        aria:     { label: t('chat.voice.dialog_label') },
        tabindex: '-1',
        data:     { speech_target: 'panel' }
      ) do
        handle
        phase_section
        transcript_section
        bar_section
        actions_section
      end
    end

    def handle
      div(class: 'w-10 h-1 rounded-full bg-slate-200 mx-auto mb-4')
    end

    def phase_section
      div(class: 'flex items-center justify-center gap-2 mb-3') do
        span(class: 'w-2 h-2 rounded-full bg-violet-500 animate-pulse motion-reduce:animate-none', data: { speech_target: 'phaseDot' })
        p(
          class: 'text-xs font-semibold uppercase tracking-wider text-violet-600',
          aria:  { live: 'polite' },
          data:  { speech_target: 'phaseLabel', understood_label: t('chat.voice.understood') }
        ) { t('chat.voice.listening') }
      end
    end

    def transcript_section
      p(class: 'min-h-[56px] text-center text-lg font-semibold text-slate-800 leading-snug px-2', aria: { live: 'polite' }) do
        span(class: 'text-slate-400 font-normal text-base', data: { speech_target: 'hint' }) { t('chat.voice.hint') }
        span(data: { speech_target: 'transcript' })
        span(
          class: 'hidden w-[2px] h-[1em] bg-violet-600 ml-0.5 align-[-2px] animate-pulse motion-reduce:animate-none',
          data:  { speech_target: 'caret' }
        )
      end
    end

    def bar_section
      div(class: 'mt-4 mb-5 h-14 rounded-full bg-slate-100 pl-5 pr-4 flex items-center gap-4') do
        span(class: 'text-xl font-semibold tabular-nums text-slate-800 w-12 flex-shrink-0', data: { speech_target: 'timer' }) { '0:00' }
        wave
      end
    end

    def wave
      div(
        class: 'flex-1 min-w-0 h-8 flex items-center justify-end gap-[3px] overflow-hidden',
        aria:  { hidden: 'true' },
        data:  { speech_target: 'wave' }
      ) do
        WAVE_BARS.times do |index|
          fade = [1, (index + 1) / (WAVE_BARS * 0.25)].min
          span(
            class: 'flex-shrink-0 w-[3px] h-[3px] rounded-full bg-slate-400',
            style: "opacity: #{(0.5 + (0.5 * fade)).round(2)}"
          )
        end
      end
    end

    def actions_section
      div(class: 'flex items-center justify-between px-1') do
        discard_button
        send_button
      end
    end

    def discard_button
      button(
        type:  'button',
        class: 'w-14 h-14 rounded-full bg-red-50 text-red-500 flex items-center justify-center active:scale-95 transition-transform',
        aria:  { label: t('chat.voice.discard') },
        data:  { action: 'click->speech#cancel' }
      ) { render PhlexIcons::Lucide::Trash2.new(class: 'w-[22px] h-[22px]') }
    end

    def send_button
      button(
        type:  'button',
        class: 'w-14 h-14 rounded-full bg-violet-600 text-white flex items-center justify-center shadow-lg shadow-violet-500/30 ' \
               'active:scale-95 transition-transform',
        aria:  { label: t('chat.voice.send') },
        data:  { action: 'click->speech#send' }
      ) do
        render PhlexIcons::Lucide::Send.new(class: 'w-[22px] h-[22px]', data: { speech_target: 'sendIcon' })
        render PhlexIcons::Lucide::Check.new(class: 'hidden w-[22px] h-[22px]', data: { speech_target: 'checkIcon' })
      end
    end
  end
end
