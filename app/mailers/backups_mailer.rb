class BackupsMailer < ApplicationMailer
  def failure(error_class, message)
    mail(
      to:           Backups::Config.new.target_email,
      subject:      I18n.t('backups.mailer.failure.subject'),
      body:         I18n.t('backups.mailer.failure.body', error_class: error_class, message: message),
      content_type: 'text/plain'
    )
  end
end
