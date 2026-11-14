class Passwords::EditView < ApplicationView
  def initialize(token:, user:)
    @token = token
    @user = user
  end

  def view_template
    render LayoutComponent.new(title: t('.title'), auth: true) do
      render Auth::ShellComponent.new(title: t('.heading'), subtitle: t('.subtitle')) do |shell|
        shell.with_content { content_block }
      end
    end
  end

  private

  def content_block
    form_with(url: helpers.password_path(@token), method: :patch, data: { turbo: false }, class: 'space-y-4') do |form|
      render Auth::PasswordFieldComponent.new(
        form: form, attribute: :password, label: t('.password'), autocomplete: 'new-password',
        hint: t('.hint'), error: field_error(:password), autofocus: true
      )
      render Auth::PasswordFieldComponent.new(
        form: form, attribute: :password_confirmation, label: t('.password_confirmation'), autocomplete: 'new-password',
        error: field_error(:password_confirmation)
      )
      div(class: 'pt-1') { render Auth::CtaComponent.new(label: t('.submit'), icon: PhlexIcons::Lucide::Check) }
    end
  end

  def field_error(attribute)
    @user.errors[attribute].first
  end
end
