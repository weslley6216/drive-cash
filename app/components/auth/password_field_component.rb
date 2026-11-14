class Auth::PasswordFieldComponent < ApplicationComponent
  def initialize(form:, attribute:, label:, autocomplete:, hint: nil, error: nil, autofocus: false)
    @form = form
    @attribute = attribute
    @label = label
    @autocomplete = autocomplete
    @hint = hint
    @error = error
    @autofocus = autofocus
  end

  def view_template(&block)
    div do
      label_row(&block)
      div(class: 'relative', data: { controller: 'password-toggle' }) do
        span(class: 'absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400') do
          render PhlexIcons::Lucide::Lock.new(class: 'w-[18px] h-[18px]')
        end
        raw @form.password_field(@attribute,
                                 id:           @attribute.to_s,
                                 required:     true,
                                 autocomplete: @autocomplete,
                                 autofocus:    @autofocus,
                                 data:         { 'password-toggle-target': 'input' },
                                 class:        input_classes).to_s
        eye_toggle
      end
      hint_or_error
    end
  end

  private

  def label_row(&block)
    if block
      div(class: 'flex items-center justify-between mb-1.5') do
        label(class: 'text-xs font-semibold text-slate-600', for: @attribute.to_s) { plain @label }
        yield
      end
    else
      label(class: 'text-xs font-semibold text-slate-600 mb-1.5 block', for: @attribute.to_s) { plain @label }
    end
  end

  def eye_toggle
    button(
      type:       'button',
      aria_label: t('.show'),
      class:      'absolute right-1 top-1/2 -translate-y-1/2 w-11 h-11 flex items-center justify-center text-slate-400 cursor-pointer',
      data:       { action: 'click->password-toggle#toggle' }
    ) do
      span(data: { 'password-toggle-target': 'eye' }) { render PhlexIcons::Lucide::Eye.new(class: 'w-[18px] h-[18px]') }
      span(class: 'hidden', data: { 'password-toggle-target': 'eyeOff' }) { render PhlexIcons::Lucide::EyeOff.new(class: 'w-[18px] h-[18px]') }
    end
  end

  def hint_or_error
    if @error
      p(class: 'text-xs font-medium text-red-600 mt-1.5 flex items-center gap-1.5') do
        render PhlexIcons::Lucide::TriangleAlert.new(class: 'w-[13px] h-[13px]')
        plain @error
      end
    elsif @hint
      p(class: 'text-xs text-slate-500 mt-1.5') { plain @hint }
    end
  end

  def input_classes
    class_names(
      'w-full bg-white border rounded-xl pl-11 pr-11 py-3 text-sm text-slate-900 placeholder:text-slate-400 ' \
      'focus:outline-none focus:ring-2',
      @error ? 'border-red-300 ring-2 ring-red-100 focus:ring-red-200' : 'border-slate-200 focus:ring-blue-500 focus:border-blue-500'
    )
  end
end
