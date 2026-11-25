module RecordCreateNotice
  extend ActiveSupport::Concern

  private

  def default_create_notice(_result)
    t('records.create.success')
  end

  def expense_create_notice(result)
    return t('records.create.fuel_debited') if result.expenses.first.tank_debit?

    default_create_notice(result)
  end
end
