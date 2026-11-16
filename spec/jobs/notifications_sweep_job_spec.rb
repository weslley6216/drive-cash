require 'rails_helper'

RSpec.describe NotificationsSweepJob do
  describe '#perform' do
    it 'creates the pending notifications of every user without them opening the notification center' do
      users = create_list(:user, 2)
      users.each do |user|
        create(:earning, user: user, date: 8.days.ago.to_date)
        create(:earning, user: user, date: 15.days.ago.to_date)
      end

      described_class.perform_now

      users.each { |user| expect(user.notifications.pluck(:kind)).to include('log_reminder') }
    end

    it 'keeps sweeping the remaining users and logs the failure when one user breaks' do
      broken, healthy = create_list(:user, 2)
      sweeper = instance_double(Notifications::Sweeper, call: [])
      allow(Notifications::Sweeper).to receive(:new).and_return(sweeper)
      allow(Notifications::Sweeper).to receive(:new).with(user: broken).and_raise(StandardError, 'boom')
      allow(Rails.logger).to receive(:error)

      described_class.perform_now

      expect(Notifications::Sweeper).to have_received(:new).with(user: healthy)
      expect(Rails.logger).to have_received(:error).with(/\[Notifications\] user #{broken.id}: boom/)
    end
  end

  describe 'schedule' do
    let(:options) { YAML.load_file(Rails.root.join('config/recurring.yml')).dig('production', 'sweep_notifications') }
    let(:task) { SolidQueue::RecurringTask.from_configuration('sweep_notifications', **options.symbolize_keys) }

    it 'runs every morning at 6 in Brasília time' do
      travel_to Time.zone.local(2026, 11, 16, 7) do
        expect(task.class_name).to eq('NotificationsSweepJob')
        expect(task.next_time).to eq(Time.zone.local(2026, 11, 17, 6))
      end
    end
  end
end
