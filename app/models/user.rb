class User < ApplicationRecord
  has_secure_password
  has_many :sessions,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
  has_many :earnings,  dependent: :destroy

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(value) { value.strip.downcase }
end
