module Reauthentications
  class NewView < ApplicationView
    def initialize(error: false)
      @error = error
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), auth: true) do
        div(class: 'min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-50 to-slate-100 px-6') do
          div(class: 'w-full max-w-sm') { card }
        end
      end
    end

    private

    def card
      div(class: 'bg-white rounded-2xl border border-slate-200 shadow-sm p-8') do
        icon
        h1(class: 'text-xl font-bold text-slate-900 text-center') { t('.heading') }
        p(class: 'text-sm text-slate-500 text-center mt-2') { t('.subtitle') }
        flash_alert
        challenge_form
        cancel_link
      end
    end

    def icon
      div(class: 'w-14 h-14 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center mx-auto mb-4') do
        render PhlexIcons::Lucide::Shield.new(class: 'w-7 h-7')
      end
    end

    def flash_alert
      return if helpers.flash[:alert].blank?

      div(class: 'mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700') do
        plain helpers.flash[:alert]
      end
    end

    def challenge_form
      form_with(url: helpers.reauthentication_path, data: { turbo: false }, class: 'space-y-4 mt-6') do
        password_input
        submit_button
      end
    end

    def password_input
      div do
        label(class: 'block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1.5', for: 'password') { t('.password_label') }
        input(
          type:         'password',
          name:         'password',
          id:           'password',
          required:     true,
          autocomplete: 'current-password',
          autofocus:    true,
          class:        input_classes
        )
        field_error
      end
    end

    def field_error
      return unless @error

      p(class: 'flex items-center gap-1.5 text-xs text-red-600 mt-1.5') do
        render PhlexIcons::Lucide::TriangleAlert.new(class: 'w-[13px] h-[13px] flex-shrink-0')
        plain t('.error')
      end
    end

    def submit_button
      button(type: 'submit', class: 'w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-3.5 text-sm font-bold shadow-sm cursor-pointer') do
        plain t('.submit')
      end
    end

    def cancel_link
      p(class: 'text-center mt-4') do
        link_to(t('.cancel'), helpers.account_path, class: 'text-sm font-semibold text-slate-500 hover:text-slate-700')
      end
    end

    def input_classes
      'w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-800 outline-none focus:ring-2 focus:ring-blue-200 focus:border-blue-400'
    end
  end
end
