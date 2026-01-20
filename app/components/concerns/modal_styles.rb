# frozen_string_literal: true

module ModalStyles
  MODAL_CLASSES = {
    backdrop: 'fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50 animate-fade-in',
    content: 'bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto animate-slide-up',
    header: 'flex items-center justify-between p-6 border-b',
    title: 'text-2xl font-bold text-slate-800',
    close_button: 'text-slate-400 hover:text-slate-600 transition-colors p-2'
  }.freeze

  def modal_backdrop_classes
    MODAL_CLASSES[:backdrop]
  end

  def modal_content_classes
    MODAL_CLASSES[:content]
  end

  def modal_header_classes
    MODAL_CLASSES[:header]
  end

  def modal_title_classes
    MODAL_CLASSES[:title]
  end

  def modal_close_button_classes
    MODAL_CLASSES[:close_button]
  end
end
