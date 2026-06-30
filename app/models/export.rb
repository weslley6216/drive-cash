class Export < ApplicationRecord
  DEFAULT_INCLUDES = { 'earnings' => true, 'expenses' => true, 'refuelings' => true, 'maintenances' => false }.freeze
  INCLUDABLE = %w[earnings expenses refuelings maintenances].freeze

  belongs_to :user
  has_one_attached :file

  enum :period_kind, { this_month: 0, last_month: 1, year: 2, custom: 3 }, prefix: true
  enum :format, { pdf: 0, csv: 1, json: 2 }, prefix: true
  enum :status, { pending: 0, processing: 1, done: 2, failed: 3 }, prefix: true

  validates :period_kind, :period_start, :period_end, :format, presence: true
  validate :period_end_after_start

  before_validation :apply_period_range
  after_initialize :apply_defaults, if: :new_record?

  scope :recent, -> { order(created_at: :desc) }

  def includes_for(kind)
    includes.fetch(kind.to_s, false)
  end

  private

  def apply_period_range
    return if period_kind.blank?

    range = Exports::PeriodRange.new(
      kind:         period_kind,
      custom_start: period_start,
      custom_end:   period_end
    )

    self.period_start = range.period_start
    self.period_end = range.period_end
  end

  def apply_defaults
    self.includes = DEFAULT_INCLUDES.dup if includes.blank?
    self.status ||= 'pending'
  end

  def period_end_after_start
    return if period_start.blank? || period_end.blank?
    return if period_end >= period_start

    errors.add(:period_end, :after_start)
  end
end
