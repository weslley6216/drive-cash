class Sessions::NewView < ApplicationView
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
      hero_block
      p(class: 'text-xs text-blue-200/80') { t('.copyright') }
    end
  end

  def hero_block
    div(class: 'relative') do
      h2(class: 'text-4xl font-bold text-white tracking-tight leading-[1.15]') do
        plain t('.brand_headline_line1')
        br
        plain t('.brand_headline_line2')
      end
      p(class: 'text-base text-blue-100 mt-4 max-w-sm leading-relaxed') { t('.brand_subheadline') }
      hero_profit_card
    end
  end

  def hero_profit_card
    div(class: 'mt-8 inline-flex items-center gap-4 bg-white/10 backdrop-blur rounded-2xl px-5 py-4 border border-white/15') do
      div(class: 'w-11 h-11 rounded-xl bg-white/15 flex items-center justify-center text-white') do
        render PhlexIcons::Lucide::TrendingUp.new(class: 'w-5 h-5')
      end
      div do
        p(class: 'text-[11px] font-semibold uppercase tracking-wider text-blue-100') { t('.hero_profit_label') }
        p(class: 'text-2xl font-bold text-white tabular-nums tracking-tight mt-0.5') { format_currency(16_555.27) }
      end
    end
  end

  def form_panel
    div(class: 'flex-1 flex items-center justify-center p-6 lg:p-8 bg-gradient-to-br from-slate-50 to-slate-100') do
      div(class: 'w-full max-w-sm') do
        mobile_brand_header
        flash_banner
        form_block
      end
    end
  end

  def mobile_brand_header
    div(class: 'pt-4 pb-8 lg:hidden') do
      render BrandMarkComponent.new(size: :lg)
    end
  end

  def form_block
    h1(class: 'text-3xl font-bold text-slate-900 tracking-tight') { t('.welcome') }
    p(class: 'text-sm text-slate-500 mt-2') { t('.welcome_subtitle') }
    form_with(url: helpers.session_path, data: { turbo: false }, class: 'space-y-4 mt-8') do |form|
      email_field(form)
      password_field(form)
      remember_me_block
      submit_button
    end
    divider_block
    google_button
    footer_links
  end

  def email_field(form)
    div do
      label(class: 'text-xs font-semibold text-slate-600 mb-1.5 block', for: 'email_address') { t('.email_label') }
      div(class: 'relative') do
        span(class: 'absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400') do
          render PhlexIcons::Lucide::User.new(class: 'w-[18px] h-[18px]')
        end
        raw form.email_field(:email_address,
                             id: 'email_address',
                             required: true,
                             autocomplete: 'email',
                             autofocus: true,
                             class: input_classes(icon: true)).to_s
      end
    end
  end

  def password_field(form)
    div do
      div(class: 'flex items-center justify-between mb-1.5') do
        label(class: 'text-xs font-semibold text-slate-600', for: 'password') { t('.password_label') }
        link_to(t('.forgot_password'), helpers.new_password_path, class: 'text-xs font-semibold text-blue-600 hover:underline')
      end
      div(class: 'relative', data: { controller: 'password-toggle' }) do
        span(class: 'absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400') do
          render PhlexIcons::Lucide::Shield.new(class: 'w-[18px] h-[18px]')
        end
        raw form.password_field(:password,
                                id: 'password',
                                required: true,
                                autocomplete: 'current-password',
                                data: { 'password-toggle-target': 'input' },
                                class: input_classes(icon: true, trailing: true)).to_s
        button(
          type: 'button',
          class: 'absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 cursor-pointer',
          data: { action: 'click->password-toggle#toggle' }
        ) do
          span(data: { 'password-toggle-target': 'eye' }) do
            render PhlexIcons::Lucide::Eye.new(class: 'w-[18px] h-[18px]')
          end
          span(class: 'hidden', data: { 'password-toggle-target': 'eyeOff' }) do
            render PhlexIcons::Lucide::EyeOff.new(class: 'w-[18px] h-[18px]')
          end
        end
      end
    end
  end

  def remember_me_block
    div(class: 'flex items-center gap-2.5 pt-1') do
      input(type: 'hidden', name: 'remember_me', value: '0')
      input(
        type: 'checkbox',
        name: 'remember_me',
        value: '1',
        id: 'remember_me',
        class: 'w-5 h-5 rounded-md border-slate-300 text-blue-600 focus:ring-blue-500 cursor-pointer'
      )
      label(for: 'remember_me', class: 'text-sm text-slate-600 cursor-pointer') { t('.remember_me') }
    end
  end

  def submit_button
    button(
      type: 'submit',
      class: 'w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-3.5 text-sm font-semibold shadow-lg shadow-blue-600/25 flex items-center justify-center gap-2 mt-2 cursor-pointer'
    ) do
      plain t('.sign_in')
      render PhlexIcons::Lucide::ArrowRight.new(class: 'w-4 h-4 stroke-[2.4]')
    end
  end

  def divider_block
    div(class: 'flex items-center gap-3 py-1') do
      div(class: 'flex-1 h-px bg-slate-200')
      span(class: 'text-xs text-slate-400') { t('.divider') }
      div(class: 'flex-1 h-px bg-slate-200')
    end
  end

  def google_button
    form(action: '/auth/google_oauth2', method: 'post', data: { turbo: 'false' }) do
      raw helpers.hidden_field_tag(:authenticity_token, helpers.form_authenticity_token)
      button(
        type: 'submit',
        class: 'w-full flex items-center justify-center gap-2.5 bg-white border border-slate-200 rounded-xl py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 cursor-pointer'
      ) do
        span(class: 'w-5 h-5 rounded-full bg-gradient-to-br from-blue-500 via-emerald-500 to-amber-500 flex items-center justify-center text-white text-[11px] font-bold') { 'G' }
        span { t('.google') }
      end
    end
  end

  def footer_links
    p(class: 'text-sm text-slate-500 text-center mt-8') do
      plain "#{t('.no_account')} "
      link_to(t('.create_account'), helpers.new_registration_path, class: 'font-semibold text-blue-600 hover:underline')
    end
  end

  def flash_banner
    if helpers.flash[:notice].present?
      div(class: 'mb-4 rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700') do
        plain helpers.flash[:notice]
      end
    end

    if helpers.flash[:alert].present?
      div(class: 'mb-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700') do
        plain helpers.flash[:alert]
      end
    end
  end

  def input_classes(icon: false, trailing: false)
    [
      'w-full bg-white border border-slate-200 rounded-xl',
      icon ? 'pl-11' : 'pl-4',
      trailing ? 'pr-11' : 'pr-4',
      'py-3 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
    ].join(' ')
  end
end
