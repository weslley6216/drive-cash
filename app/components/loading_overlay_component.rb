class LoadingOverlayComponent < ApplicationComponent
  OVERLAY_CLASSES = 'hidden fixed inset-0 lg:left-64 z-[9999] flex items-center justify-center bg-slate-900/40 backdrop-blur-sm'.freeze
  CARD_CLASSES = 'bg-white rounded-2xl shadow-xl p-6 flex flex-col items-center gap-3'.freeze
  SPINNER_CLASSES = 'w-10 h-10 rounded-full border-4 border-slate-100 border-t-blue-600 animate-spin'.freeze
  MESSAGE_CLASSES = 'hidden text-xs text-slate-500 text-center max-w-[220px] leading-snug'.freeze

  def view_template
    div(id: 'loading-overlay', class: OVERLAY_CLASSES, data: { turbo_permanent: true, controller: 'loading' }) do
      div(class: CARD_CLASSES) do
        div(class: SPINNER_CLASSES)
        p(class: MESSAGE_CLASSES, data: { loading_target: 'message' })
      end
    end
  end
end
