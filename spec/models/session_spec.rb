require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:session) { create(:user).sessions.create!(user_agent: 'test', ip_address: '127.0.0.1') }

  describe '#reauthenticated?' do
    it 'is false when the session was never reauthenticated' do
      expect(session.reauthenticated?).to be(false)
    end

    it 'is true when the reauthentication is within the window' do
      session.update!(reauthenticated_at: 1.minute.ago)

      expect(session.reauthenticated?).to be(true)
    end

    it 'is false when the reauthentication is older than the window' do
      session.update!(reauthenticated_at: (Session::REAUTHENTICATION_WINDOW + 1.minute).ago)

      expect(session.reauthenticated?).to be(false)
    end
  end

  describe '#reauthenticate!' do
    it 'stamps the current time and marks the session as reauthenticated' do
      freeze_time do
        session.reauthenticate!

        expect(session.reauthenticated_at).to eq(Time.current)
        expect(session.reauthenticated?).to be(true)
      end
    end
  end
end
