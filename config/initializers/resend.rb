# Resend transactional email. The API key is only required where mail is
# actually delivered over the network (production); development and test use
# the :test delivery method and never touch Resend.
Resend.api_key = ENV['RESEND_API_KEY'] if ENV['RESEND_API_KEY'].present?
