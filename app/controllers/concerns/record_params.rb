module RecordParams
  extend ActiveSupport::Concern

  EXPENSE_ATTRIBUTES = %i[date amount category vendor description paid].freeze
  EARNING_ATTRIBUTES = %i[date amount platform notes trips_count].freeze
  INSTALLMENT_ATTRIBUTES = %i[repeat period repetitions].freeze

  private

  def expense_attribute_keys = EXPENSE_ATTRIBUTES.map(&:to_s)
  def earning_attribute_keys = EARNING_ATTRIBUTES.map(&:to_s)
  def installment_attribute_keys = INSTALLMENT_ATTRIBUTES.map(&:to_s)

  def expense_attributes(scope_key)
    params.require(scope_key).permit(*EXPENSE_ATTRIBUTES)
  end

  def earning_attributes(scope_key)
    params.require(scope_key).permit(*EARNING_ATTRIBUTES)
  end

  def installment_attributes
    params.fetch(:installment, {}).permit(*INSTALLMENT_ATTRIBUTES)
  end

  def create_expense_via_creator(scope_key)
    Expenses::Creator.call(
      expense_attributes(scope_key).to_unsafe_h,
      installment_attributes.to_unsafe_h,
      user: current_user
    )
  end
end
