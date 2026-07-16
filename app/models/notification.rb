class Notification < ApplicationRecord
  INDEX_LIMIT = 50

  belongs_to :user

  validates :kind, presence: true, inclusion: { in: Notifications::Registry::KINDS }

  scope :unread, -> { where(read_at: nil) }
  scope :chronological, -> { order(created_at: :desc) }
  scope :recent, -> { chronological.limit(INDEX_LIMIT) }

  def self.mark_all_read!
    update_all(read_at: Time.current)
  end

  def unread? = read_at.nil?

  def mark_read!
    update!(read_at: Time.current) if unread?
  end
end
