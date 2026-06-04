class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM', 'no-reply@drivecash.net.br')
  layout nil
end
