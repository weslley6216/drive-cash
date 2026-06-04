require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = build(:user)

    expect(user).to be_valid
  end

  it 'is invalid without name' do
    user = build(:user, name: nil)

    expect(user).not_to be_valid
  end

  it 'is invalid without email_address' do
    user = build(:user, email_address: nil)

    expect(user).not_to be_valid
  end

  it 'is invalid when password is shorter than 8 characters' do
    user = build(:user, password: 'short', password_confirmation: 'short')

    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end

  it 'is invalid when password_confirmation does not match password' do
    user = build(:user, password: 'password123', password_confirmation: 'different123')

    expect(user).not_to be_valid
    expect(user.errors[:password_confirmation]).to be_present
  end

  it 'normalizes email_address by stripping and downcasing' do
    user = create(:user, email_address: '  Driver@DriveCash.Test  ')

    expect(user.email_address).to eq('driver@drivecash.test')
  end

  it 'authenticates with correct password' do
    user = create(:user)

    expect(User.authenticate_by(email_address: user.email_address, password: 'password123')).to eq(user)
  end

  it 'rejects authentication with wrong password' do
    user = create(:user)

    expect(User.authenticate_by(email_address: user.email_address, password: 'wrong')).to be_nil
  end

  it 'has many expenses destroyed with user' do
    user = create(:user)
    create(:expense, user: user)

    expect { user.destroy }.to change(Expense, :count).by(-1)
  end

  it 'has many earnings destroyed with user' do
    user = create(:user)
    create(:earning, user: user)

    expect { user.destroy }.to change(Earning, :count).by(-1)
  end

  describe '#first_name' do
    it 'returns the first word of the name' do
      user = build(:user, name: 'Weslley Campos')

      expect(user.first_name).to eq('Weslley')
    end

    it 'handles single-word names' do
      user = build(:user, name: 'Weslley')

      expect(user.first_name).to eq('Weslley')
    end
  end

  describe 'password_reset token' do
    it 'generates a token and finds the user back by it' do
      user = create(:user)

      token = user.password_reset_token

      expect(User.find_by_password_reset_token!(token)).to eq(user)
    end

    it 'raises InvalidSignature when the token string is malformed' do
      expect { User.find_by_password_reset_token!('not-a-real-token') }
        .to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
    end

    it 'invalidates previous tokens when the password changes' do
      user  = create(:user)
      token = user.password_reset_token

      user.update!(password: 'newpassword123', password_confirmation: 'newpassword123')

      expect { User.find_by_password_reset_token!(token) }
        .to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
    end

    it 'expires the token after 15 minutes' do
      user  = create(:user)
      token = user.password_reset_token

      travel_to 16.minutes.from_now do
        expect { User.find_by_password_reset_token!(token) }
          .to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end
  end

  describe '.find_or_create_from_oauth' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid:      '1234567890',
        info:     { email: 'oauth-user@drivecash.test', name: 'OAuth User' }
      )
    end

    it 'creates a new user when provider and uid do not exist' do
      expect { User.find_or_create_from_oauth(auth) }.to change(User, :count).by(1)
    end

    it 'sets provider, uid and a random password on new oauth users' do
      user = User.find_or_create_from_oauth(auth)

      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('1234567890')
      expect(user.email_address).to eq('oauth-user@drivecash.test')
      expect(user.password_digest).to be_present
    end

    it 'returns the existing user when provider and uid already exist' do
      existing = User.find_or_create_from_oauth(auth)

      expect { User.find_or_create_from_oauth(auth) }.not_to change(User, :count)
      expect(User.find_or_create_from_oauth(auth)).to eq(existing)
    end

    it 'links provider and uid to an existing user with matching email' do
      existing = create(:user, email_address: 'oauth-user@drivecash.test')

      result = User.find_or_create_from_oauth(auth)

      expect(result).to eq(existing)
      expect(existing.reload.provider).to eq('google_oauth2')
      expect(existing.uid).to eq('1234567890')
    end
  end
end
