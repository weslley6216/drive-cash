module Profiles
  class EditView < ApplicationView
    def initialize(user:, reauthenticated:)
      @user = user
      @reauthenticated = reauthenticated
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :more, sidebar_nav: :more) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }
        form_with(model: @user, url: helpers.profile_path, method: :patch, class: 'contents') do |form|
          mobile_header
          desktop_header
          fields_card(form)
          mobile_cta
        end
      end
    end

    private

    def desktop_header
      div(class: 'hidden lg:flex mb-6 items-end justify-between') do
        div do
          h1(class: 'text-2xl font-bold text-slate-800') { t('.heading') }
          p(class: 'text-sm text-slate-500 mt-1') { t('.desktop_subtitle') }
        end
        div(class: 'w-56') { save_button }
      end
    end

    def fields_card(form)
      div(class: 'px-5 pb-28 lg:px-0 lg:pb-0') do
        div(class: 'space-y-6 lg:max-w-xl lg:bg-white lg:rounded-2xl lg:border lg:border-slate-200 lg:p-8') do
          avatar
          identity_fields(form)
          security_section(form)
        end
      end
    end

    def mobile_header
      header(class: 'px-5 pt-2 pb-3 lg:hidden') do
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
        render AvatarComponent.new(name: @user.name, size_classes: 'w-[84px] h-[84px] text-3xl')
      end
    end

    def identity_fields(form)
      div(class: 'space-y-4') do
        profile_field(form, :name, label: t('.name'))
        email_field(form)
        profile_field(form, :phone, label: t('.phone'), type: 'tel')
      end
    end

    def email_field(form)
      return profile_field(form, :email_address, label: t('.email'), type: 'email') if @reauthenticated

      reauth_locked(label: t('.email'), prompt: t('.email_locked'), value: @user.email_address)
    end

    def security_section(form)
      div do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') { t('.security') }
        @reauthenticated ? password_fields(form) : reauth_locked(label: t('.change_password'), prompt: t('.password_locked'))
      end
    end

    def password_fields(form)
      div(class: 'space-y-4') do
        p(class: 'text-xs text-slate-500') { t('.change_password_hint') }
        password_field(form, :password, label: t('.new_password'))
        password_field(form, :password_confirmation, label: t('.confirm_password'))
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

    def password_field(form, attribute, label:)
      error = @user.errors[attribute].first
      div do
        field_label(form, attribute, label)
        render form.password_field(attribute, autocomplete: 'new-password', class: field_input_classes(error))
        field_error(error)
      end
    end

    def reauth_locked(label:, prompt:, value: nil)
      div do
        plain_label(label)
        div(class: 'rounded-xl border border-slate-200 bg-slate-50 px-4 py-3') do
          p(class: 'text-sm text-slate-700 truncate') { value } if value
          link_to(helpers.new_reauthentication_path, class: "flex items-center gap-1.5 text-xs font-semibold text-blue-600 hover:underline #{'mt-2' if value}") do
            render PhlexIcons::Lucide::Shield.new(class: 'w-[13px] h-[13px] flex-shrink-0')
            plain prompt
          end
        end
      end
    end

    def field_label(form, attribute, label)
      label(class: 'block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1.5', for: form.field_id(attribute)) { label }
    end

    def plain_label(text)
      label(class: 'block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1.5') { text }
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
