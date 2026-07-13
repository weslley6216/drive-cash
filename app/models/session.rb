class Session < ApplicationRecord
  REAUTHENTICATION_WINDOW = 15.minutes

  belongs_to :user

  def reauthenticated?
    reauthenticated_at.present? && reauthenticated_at > REAUTHENTICATION_WINDOW.ago
  end

  def reauthenticate!
    update!(reauthenticated_at: Time.current)
  end
end
