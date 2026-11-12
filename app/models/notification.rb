class Notification < ApplicationRecord
  INDEX_LIMIT = 50
  READ_RETENTION = 7.days

  belongs_to :user

  validates :kind, presence: true, inclusion: { in: Notifications::Registry::KINDS }

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :retained, -> { unread.or(where(read_at: READ_RETENTION.ago..)) }
  scope :visible, -> { where(dismissed_at: nil) }
  scope :chronological, -> { order(created_at: :desc) }
  scope :recent, -> { chronological.limit(INDEX_LIMIT) }

  def self.mark_all_read!
    update_all(read_at: Time.current)
  end

  def self.dismiss_all!
    update_all(dismissed_at: Time.current)
  end

  def unread? = read_at.nil?

  def mark_read!
    update!(read_at: Time.current) if unread?
  end

  def dismiss!
    update!(dismissed_at: Time.current) unless dismissed_at
  end
end
