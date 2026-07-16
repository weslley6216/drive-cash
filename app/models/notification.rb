class Notification < ApplicationRecord
  belongs_to :user

  validates :kind, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :chronological, -> { order(created_at: :desc) }

  def self.mark_all_read!
    update_all(read_at: Time.current)
  end

  def unread? = read_at.nil?

  def mark_read!
    update!(read_at: Time.current) if unread?
  end
end
