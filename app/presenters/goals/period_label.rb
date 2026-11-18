module Goals
  class PeriodLabel
    def initialize(kind:, period:)
      @kind = kind
      @period = period
    end

    def short
      I18n.t("goals.periods.short.#{@kind}", **parts)
    end

    def full
      I18n.t("goals.periods.full.#{@kind}", **parts)
    end

    private

    def parts
      {
        month:      I18n.t('date.month_names')[@period.first.month],
        month_year: I18n.l(@period.first, format: :month_dot_year).capitalize,
        start:      I18n.l(@period.first, format: :day_abbr),
        end:        I18n.l(@period.last, format: :day_abbr),
        year:       @period.last.year
      }
    end
  end
end
