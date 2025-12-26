require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(email_address: 'user@example.com', password: 'password123')
      expect(user).to be_valid
    end

    it 'requires an email address' do
      user = User.new(password: 'password123')
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("can't be blank")
    end

    it 'requires a password' do
      user = User.new(email_address: 'user@example.com')
      expect(user).not_to be_valid
    end

    it 'requires a unique email address' do
      User.create!(email_address: 'user@example.com', password: 'password123')
      duplicate_user = User.new(email_address: 'user@example.com', password: 'password123')
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email_address]).to include("has already been taken")
    end

    it 'enforces email uniqueness at database level' do
      User.create!(email_address: 'user@example.com', password: 'password123')
      duplicate_user = User.new(email_address: 'user@example.com', password: 'password123')
      expect { duplicate_user.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'email normalization' do
    it 'downcases email addresses' do
      user = User.create!(email_address: 'USER@EXAMPLE.COM', password: 'password123')
      expect(user.email_address).to eq('user@example.com')
    end

    it 'strips whitespace from email addresses' do
      user = User.create!(email_address: '  user@example.com  ', password: 'password123')
      expect(user.email_address).to eq('user@example.com')
    end

    it 'handles mixed case and whitespace' do
      user = User.create!(email_address: '  UsEr@ExAmPlE.cOm  ', password: 'password123')
      expect(user.email_address).to eq('user@example.com')
    end
  end

  describe 'password authentication' do
    let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrongpassword')).to be_falsey
    end

    it 'requires password confirmation to match when provided' do
      user = User.new(
        email_address: 'new@example.com',
        password: 'password123',
        password_confirmation: 'different'
      )
      expect(user).not_to be_valid
    end

    it 'stores password securely as digest' do
      expect(user.password_digest).not_to eq('password123')
      expect(user.password_digest).to be_present
    end
  end

  describe 'associations' do
    let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }

    it 'has many sessions' do
      expect(user).to respond_to(:sessions)
    end

    it 'can create associated sessions' do
      session = user.sessions.create!(ip_address: '127.0.0.1', user_agent: 'Test Browser')
      expect(user.sessions).to include(session)
    end

    it 'destroys associated sessions when user is destroyed' do
      session = user.sessions.create!(ip_address: '127.0.0.1', user_agent: 'Test Browser')
      session_id = session.id

      user.destroy

      expect(Session.find_by(id: session_id)).to be_nil
    end
  end

  describe '.authenticate_by' do
    let!(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }

    it 'returns user with correct email and password' do
      result = User.authenticate_by(email_address: 'user@example.com', password: 'password123')
      expect(result).to eq(user)
    end

    it 'returns nil with incorrect password' do
      result = User.authenticate_by(email_address: 'user@example.com', password: 'wrongpassword')
      expect(result).to be_nil
    end

    it 'returns nil with non-existent email' do
      result = User.authenticate_by(email_address: 'nonexistent@example.com', password: 'password123')
      expect(result).to be_nil
    end

    it 'handles normalized email addresses' do
      result = User.authenticate_by(email_address: 'USER@EXAMPLE.COM', password: 'password123')
      expect(result).to eq(user)
    end
  end
end
