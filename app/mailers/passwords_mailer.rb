class PasswordsMailer < ApplicationMailer
  def reset(user)
    token = user.generate_token_for(:password_reset)
    url   = edit_password_url(token)
    body  = I18n.t('passwords.mailer.reset.body', name: user.first_name, url: url)

    mail(
      to:           user.email_address,
      subject:      I18n.t('passwords.mailer.reset.subject'),
      body:         body,
      content_type: 'text/plain'
    )
  end
end
