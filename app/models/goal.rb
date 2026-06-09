class Goal < ApplicationRecord
  KINDS = %w[weekly monthly annual].freeze
  METRICS = %w[profit earnings].freeze

  belongs_to :user

  enum :kind, KINDS.zip(KINDS).to_h, prefix: true
  enum :metric, METRICS.zip(METRICS).to_h, prefix: true

  validates :target_amount, presence: true, numericality: { greater_than: 0, allow_blank: true }
  validates :period_start, :period_end, presence: true
  validates :kind, uniqueness: { scope: [:user_id, :period_start] }
  validate :period_consistency

  scope :active_at, ->(date) { where('period_start <= ? AND period_end >= ?', date, date) }
  scope :for_kind, ->(kind) { where(kind: kind) }

  private

  def period_consistency
    return if period_start.blank? || period_end.blank?

    errors.add(:period_end, :after_start) if period_end <= period_start
  end
end
