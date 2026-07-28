module RequiresBackupToken
  extend ActiveSupport::Concern

  BEARER_PREFIX = 'Bearer '.freeze

  included do
    before_action :require_backup_token
  end

  private

  def require_backup_token
    head :unauthorized unless valid_backup_token?
  end

  def valid_backup_token?
    expected = ENV['BACKUP_TRIGGER_TOKEN'].to_s
    return false if expected.blank?

    ActiveSupport::SecurityUtils.secure_compare(expected, presented_backup_token)
  end

  def presented_backup_token
    header = request.headers['Authorization'].to_s
    header.start_with?(BEARER_PREFIX) ? header.delete_prefix(BEARER_PREFIX) : ''
  end
end
