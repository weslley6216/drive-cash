module AuthenticationHelpers
  def login_as(user, remember_me: false)
    Rails.cache.clear
    post session_path, params: {
      email_address: user.email_address,
      password:      'password123',
      remember_me:   remember_me ? '1' : '0'
    }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
