class Registrations::NewView < ApplicationView
  def initialize(user:)
    @user = user
  end

  def view_template
    render LayoutComponent.new(title: t('.title'), auth: true) do
      div(class: 'min-h-screen flex bg-white') do
        desktop_brand_panel
        form_panel
      end
    end
  end

  private

  def desktop_brand_panel
    div(
      class: 'hidden lg:flex w-[46%] flex-col justify-between p-12 relative overflow-hidden',
      style: 'background: linear-gradient(150deg,#1d4ed8 0%,#2563eb 55%,#3b82f6 100%)'
    ) do
      render BrandMarkComponent.new(size: :lg, light: true)
      div(class: 'relative') do
        h2(class: 'text-4xl font-bold text-white tracking-tight leading-[1.15]') do
          plain t('sessions.new_view.brand_headline_line1')
          br
          plain t('sessions.new_view.brand_headline_line2')
        end
        p(class: 'text-base text-blue-100 mt-4 max-w-sm leading-relaxed') do
          t('sessions.new_view.brand_subheadline')
        end
      end
      p(class: 'text-xs text-blue-200/80') { t('sessions.new_view.copyright') }
    end
  end

  def form_panel
    div(class: 'flex-1 flex items-center justify-center p-6 lg:p-8 bg-gradient-to-br from-slate-50 to-slate-100') do
      div(class: 'w-full max-w-sm') do
        div(class: 'pt-4 pb-8 lg:hidden') { render BrandMarkComponent.new(size: :lg) }
        h1(class: 'text-3xl font-bold text-slate-900 tracking-tight') { t('.headline') }
        p(class: 'text-sm text-slate-500 mt-2') { t('.subtitle') }
        errors_block if @user.errors.any?
        form_block
        footer_links
      end
    end
  end

  def errors_block
    div(class: 'mt-6 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700') do
      ul(class: 'space-y-1') do
        @user.errors.full_messages.each { |message| li { message } }
      end
    end
  end

  def form_block
    form_with(model: @user, url: helpers.registrations_path, data: { turbo: false }, class: 'space-y-4 mt-8') do |form|
      text_input(form, :name,                 icon: PhlexIcons::Lucide::User, label: t('.name_label'),                 autocomplete: 'name', autofocus: true)
      text_input(form, :email_address,        icon: PhlexIcons::Lucide::Mail, label: t('.email_label'),                autocomplete: 'email', type: :email)
      password_input(form, :password,                 label: t('.password_label'),                autocomplete: 'new-password')
      password_input(form, :password_confirmation,    label: t('.password_confirmation_label'),   autocomplete: 'new-password')
      submit_button
    end
  end

  def text_input(form, name, icon:, label:, autocomplete:, type: :text, autofocus: false)
    div do
      label(class: 'text-xs font-semibold text-slate-600 mb-1.5 block', for: name.to_s) { label }
      div(class: 'relative') do
        span(class: 'absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400') do
          render icon.new(class: 'w-[18px] h-[18px]')
        end
        helper_method = type == :email ? :email_field : :text_field
        raw form.public_send(helper_method, name,
                             id: name.to_s,
                             required: true,
                             autocomplete: autocomplete,
                             autofocus: autofocus,
                             class: input_classes).to_s
      end
    end
  end

  def password_input(form, name, label:, autocomplete:)
    div do
      label(class: 'text-xs font-semibold text-slate-600 mb-1.5 block', for: name.to_s) { label }
      div(class: 'relative') do
        span(class: 'absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400') do
          render PhlexIcons::Lucide::Shield.new(class: 'w-[18px] h-[18px]')
        end
        raw form.password_field(name,
                                id: name.to_s,
                                required: true,
                                autocomplete: autocomplete,
                                class: input_classes).to_s
      end
    end
  end

  def submit_button
    button(
      type: 'submit',
      class: 'w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-3.5 text-sm font-semibold shadow-lg shadow-blue-600/25 flex items-center justify-center gap-2 mt-2'
    ) do
      plain t('.submit')
      render PhlexIcons::Lucide::ArrowRight.new(class: 'w-4 h-4 stroke-[2.4]')
    end
  end

  def footer_links
    p(class: 'text-sm text-slate-500 text-center mt-8') do
      plain "#{t('.already_have_account')} "
      link_to(t('.sign_in'), helpers.new_session_path, class: 'font-semibold text-blue-600 hover:underline')
    end
  end

  def input_classes
    'w-full bg-white border border-slate-200 rounded-xl pl-11 pr-4 py-3 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
  end
end
