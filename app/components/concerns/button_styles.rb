# frozen_string_literal: true

module ButtonStyles
  BUTTON_VARIANTS = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700',
    secondary: 'border border-slate-300 text-slate-700 hover:bg-slate-50',
    danger: 'bg-red-600 text-white hover:bg-red-700'
  }.freeze

  def button_classes(variant: :primary, full_width: false)
    base = 'px-4 py-2 rounded-lg font-medium transition-colors'
    width = full_width ? 'w-full' : ''
    variant_class = BUTTON_VARIANTS[variant] || BUTTON_VARIANTS[:primary]

    [base, variant_class, width].join(' ').strip
  end
end
