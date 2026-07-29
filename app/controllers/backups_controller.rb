class BackupsController < ApplicationController
  include RequiresBackupToken

  allow_unauthenticated_access
  skip_forgery_protection

  def create
    BackupJob.perform_later
    head :accepted
  end
end
