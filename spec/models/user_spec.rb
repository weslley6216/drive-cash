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
end
