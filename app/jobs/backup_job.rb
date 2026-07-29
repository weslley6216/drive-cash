class BackupJob < ApplicationJob
  queue_as :default

  def perform
    Backups::SheetSync.call
  rescue StandardError => e
    Rails.logger.error "[Backups] #{e.full_message(highlight: false)}"
    BackupsMailer.failure(e.class.name, e.message).deliver_later
    raise
  end
end
