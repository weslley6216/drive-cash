module Reauthentications
  class NewView < ApplicationView
    include TopbarStyles

    def initialize(error: false)
      @error = error
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), sidebar_nav: :more) do
        render ScreenComponent.new do |screen|
          screen.with_header do
            mobile_header
            desktop_header
          end
          screen.with_content { card }
        end
      end
    end

    private

    def mobile_header
      div(class: "#{PHONE_BAR} flex items-start gap-2 lg:hidden") do
        link_to(helpers.edit_profile_path, class: 'p-1 -ml-1 mt-0.5 text-slate-500', aria_label: t('.back')) do
          render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
        end
        h1(class: 'text-2xl font-bold text-slate-800 leading-tight') { t('.header') }
      end
    end

    def desktop_header
      div(class: "hidden lg:block #{DESKTOP_BAR}") do
        h1(class: 'text-2xl font-bold text-slate-900 tracking-tight') { t('.header') }
        p(class: 'text-sm text-slate-500 mt-0.5') { t('.topbar_subtitle') }
      end
    end

    def card
      div(class: 'bg-white rounded-xl lg:rounded-2xl shadow-sm lg:shadow-none border border-slate-100 lg:border-slate-200 p-5 lg:p-6 lg:max-w-sm lg:mx-auto lg:mt-8') do
        icon
        h2(class: 'text-2xl lg:text-xl font-bold text-slate-900 tracking-tight mt-5') { t('.heading') }
        p(class: 'text-sm text-slate-500 mt-2 leading-relaxed') { t('.subtitle') }
        challenge_form
      end
    end

    def icon
      div(class: 'w-14 h-14 rounded-full bg-blue-50 border border-blue-100 flex items-center justify-center text-blue-600') do
        render PhlexIcons::Lucide::Shield.new(class: 'w-[26px] h-[26px]')
      end
    end

    def challenge_form
      form_with(url: helpers.reauthentication_path, data: { turbo: false }, class: 'space-y-4 mt-6') do |form|
        render(
          Auth::PasswordFieldComponent.new(
            form: form, attribute: :password, label: t('.password_label'), autocomplete: 'current-password',
            autofocus: true, error: (t('.error') if @error)
          )
        ) { forgot_password_link }
        render Auth::CtaComponent.new(label: t('.submit'), icon: nil)
      end
    end

    def forgot_password_link
      link_to(t('.forgot_password'), helpers.new_password_path, class: 'text-xs font-semibold text-blue-600 hover:underline')
    end
  end
end
