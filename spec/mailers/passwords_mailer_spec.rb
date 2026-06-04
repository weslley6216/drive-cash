require 'rails_helper'

RSpec.describe PasswordsMailer, type: :mailer do
  let(:user) { create(:user, name: 'Weslley Campos', email_address: 'driver@drivecash.test') }

  describe '#reset' do
    it 'sends to the user with the i18n subject' do
      mail = described_class.reset(user)

      expect(mail.to).to eq([user.email_address])
      expect(mail.subject).to eq(I18n.t('passwords.mailer.reset.subject'))
    end

    it 'renders the body with the user first name and a reset link' do
      mail = described_class.reset(user)

      expect(mail.body.encoded).to include('Weslley')
      expect(mail.body.encoded).to match(%r{http://test\.host/passwords/[^/]+/edit})
    end

    it 'delivers the email when sent via deliver_now' do
      expect { described_class.reset(user).deliver_now }
        .to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
