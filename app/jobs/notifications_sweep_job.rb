class NotificationsSweepJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      Notifications::Sweeper.new(user: user).call
    rescue StandardError => e
      Rails.logger.error "[Notifications] user #{user.id}: #{e.message}"
    end
  end
end
