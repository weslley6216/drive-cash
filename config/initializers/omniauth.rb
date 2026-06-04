Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV['GOOGLE_CLIENT_ID'].present? && ENV['GOOGLE_CLIENT_SECRET'].present?
    provider :google_oauth2,
             ENV['GOOGLE_CLIENT_ID'],
             ENV['GOOGLE_CLIENT_SECRET'],
             scope: 'email,profile'
  end
end

OmniAuth.config.on_failure = proc do |env|
  SessionsController.action(:oauth_failure).call(env)
end
