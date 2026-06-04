class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM', 'no-reply@drivecash.app')
  layout nil
end
