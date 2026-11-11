module Maintenances
  class MarkDoneRequest
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :done_km, :integer
    attribute :done_on, :date

    validates :done_km, presence: true, numericality: { greater_than: 0, only_integer: true }
    validate :done_km_meets_last_km, if: -> { done_km.present? }
    validate :done_km_within_margin, if: -> { done_km.present? }

    attr_reader :maintenance, :companion_ids

    def self.model_name
      ActiveModel::Name.new(self, nil, 'mark_done')
    end

    def initialize(maintenance:, done_km: nil, done_on: nil, companion_ids: nil)
      super()
      @maintenance = maintenance
      self.done_km = done_km.nil? ? maintenance.vehicle.odometer_km : done_km
      self.done_on = done_on.presence || Date.current
      @companion_ids = normalized_companion_ids(companion_ids)
    end

    def companions
      maintenance.companions.where(id: companion_ids)
    end

    def targets
      [maintenance, *companions]
    end

    private

    def normalized_companion_ids(companion_ids)
      return [maintenance.companions.first&.id].compact if companion_ids.nil?

      Array(companion_ids).reject(&:blank?)
    end

    def done_km_meets_last_km
      if done_km < maintenance.last_done_km
        errors.add(:done_km, I18n.t('maintenances.mark_done.errors.below_last', km: delimited(maintenance.last_done_km)))
      end

      companions.each do |companion|
        next unless done_km < companion.last_done_km

        errors.add(:done_km, I18n.t('maintenances.mark_done.errors.below_last_companion',
                                    item: I18n.t("vehicle.maintenances.catalog.#{companion.category}"),
                                    km:   delimited(companion.last_done_km)))
      end
    end

    def done_km_within_margin
      return if done_km <= maintenance.max_done_km

      errors.add(:done_km, I18n.t('maintenances.mark_done.errors.above_max', km: delimited(maintenance.max_done_km)))
    end

    def delimited(value)
      ActiveSupport::NumberHelper.number_to_delimited(value, delimiter: '.')
    end
  end
end
