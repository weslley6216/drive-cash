class Sessions::NewView < ApplicationView
  def view_template
    render LayoutComponent.new(title: t('.title'), auth: true) do
      render Auth::ShellComponent.new(
        title: t('.welcome'), subtitle: t('.welcome_subtitle'), desktop_subtitle: t('.welcome_subtitle_desktop')
      ) do |shell|
        shell.with_content { content_block }
        shell.with_footer { footer_links }
      end
    end
  end

  private

  def content_block
    form_with(url: helpers.session_path, data: { turbo: false }, class: 'space-y-4') do |form|
      render Auth::FieldComponent.new(
        form: form, attribute: :email_address, label: t('.email_label'), icon: PhlexIcons::Lucide::Mail,
        type: :email, autocomplete: 'email', autofocus: true
      )
      password_field(form)
      remember_me_block
      div(class: 'pt-1') { render Auth::CtaComponent.new(label: t('.sign_in')) }
    end
    div(class: 'space-y-4 mt-4') do
      render Auth::OrDividerComponent.new
      render Auth::GoogleButtonComponent.new
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
                                id:           'password',
                                required:     true,
                                autocomplete: 'current-password',
                                data:         { 'password-toggle-target': 'input' },
                                class:        input_classes).to_s
        button(
          type:  'button',
          class: 'absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 cursor-pointer',
          data:  { action: 'click->password-toggle#toggle' }
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
        type:  'checkbox',
        name:  'remember_me',
        value: '1',
        id:    'remember_me',
        class: 'w-5 h-5 rounded-md border-slate-300 text-blue-600 focus:ring-blue-500 cursor-pointer'
      )
      label(for: 'remember_me', class: 'text-sm text-slate-600 cursor-pointer') { t('.remember_me') }
    end
  end

  def footer_links
    p(class: 'text-sm text-slate-500') do
      plain "#{t('.no_account')} "
      link_to(t('.create_account'), helpers.new_registration_path, class: 'font-semibold text-blue-600 hover:underline')
    end
  end

  def input_classes
    'w-full bg-white border border-slate-200 rounded-xl pl-11 pr-11 py-3 text-sm text-slate-900 placeholder:text-slate-400 ' \
    'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
  end
end
