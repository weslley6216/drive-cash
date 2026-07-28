class BackupsController < ApplicationController
  include RequiresBackupToken

  allow_unauthenticated_access
  skip_forgery_protection

  def create
    Backups::SheetSync.call
    head :ok
  rescue StandardError => e
    Rails.logger.error "[Backups] #{e.full_message(highlight: false)}"
    head :internal_server_error
  end
end
