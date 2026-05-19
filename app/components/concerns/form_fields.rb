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

  def money_field(form, attribute, label:, theme: :blue, required: false)
    field_wrapper(label, theme: theme) do
      render form.number_field(
        attribute,
        step: '0.01',
        required: required,
        value: form.object.public_send(attribute),
        placeholder: t('.placeholders.money'),
        class: input_classes(theme: theme)
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
      value = form.object.public_send(attribute) || Time.current.to_date
      render form.date_field(attribute, class: input_classes(theme: theme), value: value, **options)
    end
  end

  def text_area(form, attribute, label:, theme: :blue, rows: 2, **options)
    field_wrapper(label, theme: theme) do
      render form.text_area(attribute, rows: rows, class: "#{input_classes(theme: theme)} resize-none", **options)
    end
  end

  def integer_field(form, attribute, label:, theme: :blue, **options)
    field_wrapper(label, theme: theme) do
      render form.number_field(attribute, step: 1, min: 1, class: input_classes(theme: theme), **options)
    end
  end

  def toggle_field(form, attribute, label:, theme: :blue, on_label: nil, off_label: nil)
    styles = theme_styles(theme)
    checked = !!form.object.public_send(attribute)
    wrapper_classes = "mb-4 rounded-lg border #{styles[:border]} px-4 py-3"

    div(class: wrapper_classes) do
      div(class: 'flex items-center justify-between gap-3') do
        div do
          p(class: "text-sm font-medium #{styles[:label]}") { label }
          if on_label && off_label
            p(class: 'text-xs text-slate-500 mt-1') { checked ? on_label : off_label }
          end
        end

        label(for: form.field_id(attribute), class: 'relative inline-flex cursor-pointer items-center') do
          render form.check_box(
            attribute,
            class: 'peer sr-only'
          )
          span(class: 'h-6 w-11 rounded-full bg-slate-300 transition-colors peer-checked:bg-emerald-500')
          span(class: 'pointer-events-none absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform peer-checked:translate-x-5')
        end
      end
    end
  end
end
