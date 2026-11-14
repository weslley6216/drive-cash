class Registrations::NewView < ApplicationView
  def initialize(user:)
    @user = user
  end

  def view_template
    render LayoutComponent.new(title: t('.title'), auth: true) do
      render Auth::ShellComponent.new(title: t('.heading'), subtitle: t('.subtitle')) do |shell|
        shell.with_content { content_block }
        shell.with_footer { footer_links }
      end
    end
  end

  private

  def content_block
    form_with(model: @user, url: helpers.registrations_path, data: { turbo: false }, class: 'space-y-4') do |form|
      render Auth::FieldComponent.new(
        form: form, attribute: :name, label: t('.name_label'), icon: PhlexIcons::Lucide::User,
        autocomplete: 'name', autofocus: true, error: field_error(:name)
      )
      render Auth::FieldComponent.new(
        form: form, attribute: :email_address, label: t('.email_label'), icon: PhlexIcons::Lucide::Mail,
        type: :email, autocomplete: 'email', error: field_error(:email_address)
      )
      render Auth::PasswordFieldComponent.new(
        form: form, attribute: :password, label: t('.password_label'), autocomplete: 'new-password',
        hint: t('.password_hint'), error: field_error(:password)
      )
      render Auth::PasswordFieldComponent.new(
        form: form, attribute: :password_confirmation, label: t('.password_confirmation_label'), autocomplete: 'new-password',
        error: field_error(:password_confirmation)
      )
      div(class: 'pt-2 lg:pt-1') { render Auth::CtaComponent.new(label: t('.submit')) }
    end
    div(class: 'space-y-4 mt-4') do
      render Auth::OrDividerComponent.new
      render Auth::GoogleButtonComponent.new
    end
  end

  def footer_links
    p(class: 'text-sm text-slate-500') do
      plain "#{t('.already_have_account')} "
      link_to(t('.sign_in'), helpers.new_session_path, class: 'font-semibold text-blue-600 hover:underline')
    end
  end

  def field_error(attribute)
    @user.errors[attribute].first
  end
end
