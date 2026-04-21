module ChatRecordBuilder
  extend ActiveSupport::Concern

  private

  PERMITTED_PARAMS = {
    'create_earning' => %i[date amount platform notes],
    'create_expense' => %i[date amount category vendor description]
  }.freeze

  RECORD_MAPPING = {
    'create_earning' => Earning,
    'create_expense' => Expense
  }.freeze

  CONFIRM_I18N_KEYS = {
    'create_earning' => 'chat.confirm.success_earning',
    'create_expense' => 'chat.confirm.success_expense'
  }.freeze

  private_constant :RECORD_MAPPING

  def build_record(action, raw_params)
    return nil unless RECORD_MAPPING.key?(action)

    params_obj = raw_params.is_a?(ActionController::Parameters) ? raw_params : ActionController::Parameters.new(raw_params)
    safe_params = params_obj.permit(PERMITTED_PARAMS[action])
    RECORD_MAPPING[action].new(safe_params)
  end
end
