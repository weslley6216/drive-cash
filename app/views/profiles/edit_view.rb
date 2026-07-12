module Profiles
  class EditView < ApplicationView
    def initialize(user:)
      @user = user
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :more, sidebar_nav: :more) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }
        form_with(model: @user, url: helpers.profile_path, method: :patch, class: 'contents') do |form|
          mobile_layout(form)
          desktop_layout(form)
        end
      end
    end

    private

    def mobile_layout(form)
      div(class: 'lg:hidden pb-28') do
        mobile_header
        div(class: 'px-5 space-y-6') do
          avatar
          identity_fields(form)
          security_block(form)
        end
        mobile_cta
      end
    end

    def desktop_layout(form)
      div(class: 'hidden lg:block') do
        div(class: 'mb-6 flex items-end justify-between') do
          div do
            h1(class: 'text-2xl font-bold text-slate-800') { t('.heading') }
            p(class: 'text-sm text-slate-500 mt-1') { t('.desktop_subtitle') }
          end
          div(class: 'w-56') { save_button }
        end
        div(class: 'max-w-xl bg-white rounded-2xl border border-slate-200 p-8 space-y-6') do
          avatar
          identity_fields(form)
          security_block(form)
        end
      end
    end

    def mobile_header
      header(class: 'px-5 pt-2 pb-3') do
        div(class: 'flex items-center gap-3') do
          link_to(helpers.account_path, class: 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex items-center justify-center text-slate-600') do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[18px] h-[18px]')
          end
          h1(class: 'text-xl font-bold text-slate-900') { t('.heading') }
        end
      end
    end

    def avatar
      div(class: 'w-fit mx-auto') do
        div(class: 'w-[84px] h-[84px] rounded-full bg-blue-600 text-white flex items-center justify-center text-3xl font-bold') do
          plain @user.name.to_s.strip.first&.upcase || '?'
        end
      end
    end

    def identity_fields(form)
      div(class: 'space-y-4') do
        profile_field(form, :name, label: t('.name'))
        profile_field(form, :email_address, label: t('.email'), type: 'email')
        profile_field(form, :phone, label: t('.phone'), type: 'tel')
      end
    end

    def profile_field(form, attribute, label:, type: 'text')
      error = @user.errors[attribute].first
      div do
        field_label(form, attribute, label)
        render form.text_field(attribute, type: type, class: field_input_classes(error))
        field_error(error)
      end
    end

    def field_label(form, attribute, label)
      label(class: 'block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1.5', for: form.field_id(attribute)) { label }
    end

    def field_input_classes(error)
      state = error ? 'border-red-300 focus:ring-red-200' : 'border-slate-200 focus:ring-blue-200 focus:border-blue-400'
      "w-full rounded-xl border bg-white px-4 py-3 text-sm text-slate-800 outline-none focus:ring-2 #{state}"
    end

    def field_error(error)
      return unless error

      p(class: 'flex items-center gap-1.5 text-xs text-red-600 mt-1.5') do
        render PhlexIcons::Lucide::TriangleAlert.new(class: 'w-[13px] h-[13px] flex-shrink-0')
        plain error
      end
    end

    def security_error?
      %i[current_password password password_confirmation].any? { |attribute| @user.errors[attribute].any? }
    end

    def security_block(form)
      div(data: { controller: 'disclosure' }) do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') { t('.security') }
        div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden') do
          security_toggle
          security_panel(form)
        end
      end
    end

    def security_toggle
      button(type: 'button', data: { action: 'disclosure#toggle' }, class: 'w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-slate-50') do
        div(class: 'w-9 h-9 rounded-lg bg-slate-100 text-slate-600 flex items-center justify-center flex-shrink-0') do
          render PhlexIcons::Lucide::Shield.new(class: 'w-[17px] h-[17px]')
        end
        div(class: 'flex-1 min-w-0') do
          p(class: 'text-sm font-medium text-slate-800') { t('.change_password') }
          p(class: 'text-xs text-slate-500') { t('.change_password_hint') }
        end
        span(class: (security_error? ? 'hidden' : ''), data: { disclosure_target: 'iconClosed' }) { render PhlexIcons::Lucide::ChevronDown.new(class: 'w-4 h-4 text-slate-400') }
        span(class: (security_error? ? '' : 'hidden'), data: { disclosure_target: 'iconOpen' }) { render PhlexIcons::Lucide::ChevronUp.new(class: 'w-4 h-4 text-slate-400') }
      end
    end

    def security_panel(form)
      div(class: "#{'hidden' unless security_error?} px-4 pb-4 pt-1 space-y-4 border-t border-slate-100", data: { disclosure_target: 'panel' }) do
        password_field(form, :current_password, label: t('.current_password'))
        password_field(form, :password, label: t('.new_password'))
        password_field(form, :password_confirmation, label: t('.confirm_password'))
      end
    end

    def password_field(form, attribute, label:)
      error = @user.errors[attribute].first
      div do
        field_label(form, attribute, label)
        render form.password_field(attribute, autocomplete: 'off', class: field_input_classes(error))
        field_error(error)
      end
    end

    def mobile_cta
      div(class: 'fixed bottom-0 left-0 right-0 px-5 pt-3 pb-7 border-t border-slate-100 bg-white lg:hidden') do
        save_button
      end
    end

    def save_button
      button(type: 'submit', class: 'w-full rounded-xl py-3.5 text-sm font-bold text-white flex items-center justify-center gap-2 shadow-sm bg-blue-600 hover:bg-blue-700 cursor-pointer') do
        plain t('.save')
      end
    end
  end
end
