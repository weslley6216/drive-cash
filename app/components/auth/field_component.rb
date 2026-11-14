class Auth::FieldComponent < ApplicationComponent
  def initialize(form:, attribute:, label:, icon:, autocomplete:, type: :text, autofocus: false, error: nil)
    @form = form
    @attribute = attribute
    @label = label
    @icon = icon
    @autocomplete = autocomplete
    @type = type
    @autofocus = autofocus
    @error = error
  end

  def view_template
    div do
      label(class: 'text-xs font-semibold text-slate-600 mb-1.5 block', for: @attribute.to_s) { plain @label }
      div(class: 'relative') do
        span(class: 'absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400') do
          render @icon.new(class: 'w-[18px] h-[18px]')
        end
        raw @form.public_send(@type == :email ? :email_field : :text_field, @attribute,
                              id:           @attribute.to_s,
                              required:     true,
                              autocomplete: @autocomplete,
                              autofocus:    @autofocus,
                              class:        input_classes).to_s
      end
      error_message
    end
  end

  private

  def input_classes
    class_names(
      'w-full bg-white border rounded-xl pl-11 pr-4 py-3 text-sm text-slate-900 placeholder:text-slate-400 ' \
      'focus:outline-none focus:ring-2',
      @error ? 'border-red-300 ring-2 ring-red-100 focus:ring-red-200' : 'border-slate-200 focus:ring-blue-500 focus:border-blue-500'
    )
  end

  def error_message
    return unless @error

    p(class: 'text-xs font-medium text-red-600 mt-1.5 flex items-center gap-1.5') do
      render PhlexIcons::Lucide::TriangleAlert.new(class: 'w-[13px] h-[13px]')
      plain @error
    end
  end
end
