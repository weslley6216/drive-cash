module SystemSession
  def login_as(user)
    Rails.cache.clear
    visit new_session_path
    fill_in 'E-mail', with: user.email_address
    fill_in 'Senha', with: 'password123'
    click_on 'Entrar'
    page.has_no_button?('Entrar', disabled: :all) or raise "#{user.email_address} did not get past the login form"
  end
end

RSpec.configure do |config|
  config.include SystemSession, type: :system
end
