module Exports
  class RecentsName
    INTERPOLATIONS = {
      'year'   => ->(export) { { year: export.period_start.year } },
      'custom' => ->(export) { { start: I18n.l(export.period_start), end: I18n.l(export.period_end) } }
    }.freeze

    DEFAULT_INTERPOLATION = lambda do |export|
      { month: I18n.t('date.month_names')[export.period_start.month], year: export.period_start.year }
    end

    def initialize(export)
      @export = export
    end

    def call
      return '' if @export.period_start.blank? || @export.period_end.blank?

      options = INTERPOLATIONS.fetch(@export.period_kind, DEFAULT_INTERPOLATION).call(@export)
      I18n.t("exports.recents_name.#{@export.period_kind}", **options)
    end
  end
end
