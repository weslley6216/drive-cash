class ConfirmActionComponent < ApplicationComponent
  def initialize(title:, icon:, confirm_path:, confirm_label:, cancel_label:,
                 confirm_method: :delete, description: nil, icon_theme: :red, turbo: true)
    @title = title
    @icon = icon
    @confirm_path = confirm_path
    @confirm_method = confirm_method
    @confirm_label = confirm_label
    @cancel_label = cancel_label
    @description = description
    @icon_theme = icon_theme
    @turbo = turbo
  end

  def view_template(&block)
    div(data: { controller: 'confirm-action' }) do
      yield if block_given?
      overlay
    end
  end

  private

  def overlay
    div(class: 'fixed inset-0 z-[60] hidden', data: { 'confirm-action-target': 'overlay' }) do
      div(class: 'absolute inset-0 bg-slate-900/40', data: { action: 'click->confirm-action#dismiss' })
      mobile_sheet
      desktop_modal
    end
  end

  def mobile_sheet
    div(class: 'absolute left-0 right-0 bottom-0 bg-white rounded-t-3xl px-6 pt-3 pb-9 shadow-2xl lg:hidden') do
      div(class: 'w-10 h-1 rounded-full bg-slate-200 mx-auto mb-5')
      icon_circle(centered: true)
      h2(class: 'text-xl font-bold text-slate-900 text-center mt-4') { @title }
      p(class: 'text-sm text-slate-500 text-center mt-2 leading-relaxed') { @description } if @description
      div(class: 'space-y-2.5 mt-6') do
        confirm_form('w-full bg-red-600 hover:bg-red-700 text-white rounded-xl py-3.5 text-sm font-semibold cursor-pointer')
        button(
          type:  'button',
          class: 'w-full bg-slate-100 text-slate-700 rounded-xl py-3.5 text-sm font-semibold cursor-pointer',
          data:  { action: 'click->confirm-action#dismiss' }
        ) { @cancel_label }
      end
    end
  end

  def desktop_modal
    div(class: 'absolute inset-0 hidden lg:flex items-center justify-center p-8') do
      div(class: 'bg-white rounded-2xl shadow-2xl border border-slate-200 w-full max-w-md p-6') do
        icon_circle(centered: false)
        h2(class: 'text-xl font-bold text-slate-900 mt-4') { @title }
        p(class: 'text-sm text-slate-500 mt-2 leading-relaxed') { @description } if @description
        div(class: 'flex items-center justify-end gap-3 mt-6') do
          button(
            type:  'button',
            class: 'px-4 py-2 text-sm font-semibold text-slate-600 hover:text-slate-900 cursor-pointer',
            data:  { action: 'click->confirm-action#dismiss' }
          ) { @cancel_label }
          confirm_form('px-5 py-2 text-sm font-semibold text-white bg-red-600 hover:bg-red-700 rounded-lg cursor-pointer')
        end
      end
    end
  end

  def icon_circle(centered:)
    extra = centered ? ' mx-auto' : ''
    div(class: "#{icon_circle_classes}#{extra} flex items-center justify-center") do
      render @icon.new(class: 'w-6 h-6')
    end
  end

  def icon_circle_classes
    base = 'w-14 h-14 rounded-full'
    case @icon_theme
    when :red then "#{base} bg-red-50 text-red-600"
    when :blue then "#{base} bg-blue-50 text-blue-600"
    else "#{base} bg-slate-100 text-slate-600"
    end
  end

  def confirm_form(button_class)
    form_options = { class: 'contents' }
    form_options[:data] = { turbo: false } unless @turbo
    raw helpers.button_to(@confirm_label, @confirm_path, method: @confirm_method,
                          form: form_options, class: button_class)
  end
end
