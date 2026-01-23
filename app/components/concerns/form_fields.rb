module FormFields
  FIELD_THEMES = {
    blue: {
      text: 'text-slate-900',
      label: 'text-slate-700',
      border: 'border-slate-300',
      ring: 'focus:ring-blue-500 focus:border-blue-500',
      title: 'text-blue-700',
      modal_border: 'border-slate-200',
      header_border: 'border-slate-100',
      close_button: 'text-slate-400 hover:text-blue-600'
    },
    red: {
      text: 'text-slate-900',
      label: 'text-slate-700',
      border: 'border-slate-300',
      ring: 'focus:ring-red-500 focus:border-red-500',
      title: 'text-red-700',
      modal_border: 'border-red-200',
      header_border: 'border-red-200',
      close_button: 'text-slate-400 hover:text-red-600'
    }
  }.freeze

  def theme_styles(theme)
    FIELD_THEMES.fetch(theme, FIELD_THEMES[:blue])
  end

  def title_classes(theme: :blue) = theme_styles(theme)[:title]
  def modal_theme_classes(theme: :blue) = theme_styles(theme)[:modal_border]

  def input_classes(theme: :blue)
    styles = theme_styles(theme)
    [
      'w-full px-4 py-2 rounded-lg border focus:outline-none focus:ring-2 transition-all',
      styles[:border], styles[:text], styles[:ring]
    ].join(' ')
  end

  def field_wrapper(label_text, theme: :blue)
    styles = theme_styles(theme)
    div(class: 'mb-4') do
      label(class: "block text-sm font-medium mb-2 #{styles[:label]}") { label_text }
      yield
    end
  end

  def money_field(form, attribute, label:, theme: :blue, required: false, calculator: false)
    field_wrapper(label, theme: theme) do
      render form.number_field(
        attribute,
        step: '0.01',
        required: required,
        value: form.object.public_send(attribute),
        placeholder: t('.placeholders.money'),
        class: input_classes(theme: theme),
        data: calculator ? {
          calculator_target: 'input',
          type: calculator,
          action: 'focus->calculator#clearIfZero blur->calculator#resetIfEmpty input->calculator#calculate'
        } : {}
      )
    end
  end

  def text_field(form, attribute, label:, theme: :blue, **options)
    field_wrapper(label, theme: theme) do
      render form.text_field(attribute, class: input_classes(theme: theme), **options)
    end
  end

  def date_field(form, attribute, label:, theme: :blue, **options)
    field_wrapper(label, theme: theme) do
      render form.date_field(attribute, class: input_classes(theme: theme), **options)
    end
  end

  def text_area(form, attribute, label:, theme: :blue, rows: 2, **options)
    field_wrapper(label, theme: theme) do
      render form.text_area(attribute, rows: rows, class: "#{input_classes(theme: theme)} resize-none", **options)
    end
  end
end
