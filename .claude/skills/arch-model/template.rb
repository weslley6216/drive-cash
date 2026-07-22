class ModelName < ApplicationRecord
  include MonetaryAmount
  include VendorNormalization

  KINDS = %w[first_kind second_kind].freeze
  MIN_UNITS = 1
  MAX_UNITS = 12

  monetize :amount

  belongs_to :user
  has_many :line_items, dependent: :destroy
  has_one :attachment, dependent: :nullify

  enum :status, { pending: 0, active: 1, archived: 2 }, prefix: true, validate: true
  enum :kind, KINDS.zip(KINDS).to_h, prefix: true

  validates :amount, presence: true, numericality: { greater_than: 0, allow_blank: true }
  validates :units,
            numericality: { greater_than_or_equal_to: MIN_UNITS, less_than_or_equal_to: MAX_UNITS },
            allow_nil:    true
  validate :period_consistent

  scope :for_kind, ->(kind) { where(kind: kind) }
  scope :recent, -> { order(created_at: :desc) }

  before_save :stamp_processed_at

  def processed?
    processed_at.present?
  end

  private

  def period_consistent
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, :after_start) if ends_on <= starts_on
  end

  def stamp_processed_at
    return unless status_active?

    self.processed_at ||= Time.current
  end
end
