module Exports
  class RecentsName
    def initialize(export)
      @export = export
    end

    def call
      return '' if @export.period_start.blank? || @export.period_end.blank?

      key = "exports.recents_name.#{@export.period_kind}"
      case @export.period_kind
      when 'year'
        I18n.t(key, year: @export.period_start.year)
      when 'custom'
        I18n.t(key, start: I18n.l(@export.period_start), end: I18n.l(@export.period_end))
      else
        I18n.t(key, month: I18n.t('date.month_names')[@export.period_start.month], year: @export.period_start.year)
      end
    end
  end
end
