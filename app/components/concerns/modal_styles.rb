module ModalStyles
  MODAL_CLASSES = {
    backdrop:     'fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50 animate-fade-in',
    content:      'bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto animate-slide-up',
    header:       'flex items-center justify-between p-6 border-b gap-2',
    title:        'text-lg sm:text-2xl font-bold whitespace-nowrap min-w-0',
    close_button: 'transition-colors p-2 flex-shrink-0 cursor-pointer'
  }.freeze

  DETAIL_CARD = 'bg-white rounded-2xl shadow-2xl w-full max-w-[380px] max-h-[90vh] flex flex-col overflow-hidden ' \
                'animate-slide-up border-t-4'.freeze
  DETAIL_ACCENTS = {
    blue: { border: 'border-t-blue-600', title: 'text-blue-600', total: 'text-green-700' },
    red:  { border: 'border-t-red-600', title: 'text-red-600', total: 'text-red-700' }
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
