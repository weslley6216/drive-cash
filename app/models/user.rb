class User < ApplicationRecord
  has_secure_password
  has_many :sessions,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
  has_many :earnings,  dependent: :destroy

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :password_confirmation, presence: true, if: -> { password.present? }

  normalizes :email_address, with: ->(value) { value.strip.downcase }

  def first_name = name.split.first

  def self.find_or_create_from_oauth(auth)
    existing = find_by(provider: auth.provider, uid: auth.uid)
    return existing if existing

    by_email = find_by(email_address: auth.info.email)
    if by_email
      by_email.update!(provider: auth.provider, uid: auth.uid)
      return by_email
    end

    random_password = SecureRandom.hex(16)
    create!(
      name:                  oauth_name(auth),
      email_address:         auth.info.email,
      provider:              auth.provider,
      uid:                   auth.uid,
      password:              random_password,
      password_confirmation: random_password
    )
  end

  def self.oauth_name(auth)
    auth.info[:name].presence || auth.info.email.to_s.split('@').first
  end
  private_class_method :oauth_name
end
