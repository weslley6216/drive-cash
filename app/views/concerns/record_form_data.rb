module RecordFormData
  private

  def record_form_data(type:, selected_category:, active_vendor:, tank_balance: nil)
    { controller:                          'record-form',
      type:                                type,
      record_form_type_value:              type,
      record_form_active_vendor_value:     active_vendor,
      record_form_selected_category_value: selected_category,
      record_form_months_value:            I18n.t('date.abbr_month_names').compact.to_json,
      record_form_day_names_value:         I18n.t('date.day_names').to_json,
      record_form_today_value:             Date.current.iso8601,
      record_form_today_label_value:       t('records.new_view.today'),
      record_form_yesterday_label_value:   t('common.yesterday'),
      record_form_tank_balance_value:      tank_balance&.to_f }
  end
end
