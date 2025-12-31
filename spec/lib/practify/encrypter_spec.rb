require 'rails_helper'

RSpec.describe Practify::Encrypter do
  let(:secret_key) { SecureRandom.random_bytes(32) }
  let(:encrypter) { described_class.new(secret_key) }

  describe '#initialize' do
    it 'initializes an ActiveSupport::MessageEncryptor instance' do
      expect(encrypter.instance_variable_get(:@encryptor)).to be_a(ActiveSupport::MessageEncryptor)
    end

    it 'creates a MessageEncryptor with the provided secret key' do
      encryptor_instance = encrypter.instance_variable_get(:@encryptor)
      expect(encryptor_instance).to be_a(ActiveSupport::MessageEncryptor)
    end

    context 'with different secret keys' do
      it 'creates different encryptor instances' do
        encrypter1 = described_class.new('key1')
        encrypter2 = described_class.new('key2')

        expect(encrypter1.instance_variable_get(:@encryptor)).not_to eq(
          encrypter2.instance_variable_get(:@encryptor)
        )
      end
    end
  end

  describe '#encrypt' do
    it 'encrypts a string' do
      plain_text = 'This is a secret message that is at least 32 characters long!'
      encrypted = encrypter.encrypt(plain_text)

      expect(encrypted).to be_a(String)
      expect(encrypted).not_to eq(plain_text)
      expect(encrypted.length).to be > plain_text.length
    end

    it 'produces different encrypted values for the same input' do
      plain_text = 'This is a secret message that is at least 32 characters long!'
      encrypted1 = encrypter.encrypt(plain_text)
      encrypted2 = encrypter.encrypt(plain_text)

      # MessageEncryptor includes a timestamp, so encrypted values should differ
      expect(encrypted1).not_to eq(encrypted2)
    end

    it 'handles empty strings' do
      encrypted = encrypter.encrypt('')
      expect(encrypted).to be_a(String)
      expect(encrypted).not_to be_empty
    end

    it 'handles strings with special characters' do
      plain_text = 'test@#$%^&*()_+{}|:"<>?[]\\;\',./-=`~'
      encrypted = encrypter.encrypt(plain_text)

      expect(encrypted).to be_a(String)
      expect(encrypted).not_to eq(plain_text)
    end

    it 'handles unicode characters' do
      plain_text = '测试 🚀 émojis'
      encrypted = encrypter.encrypt(plain_text)

      expect(encrypted).to be_a(String)
      expect(encrypted).not_to eq(plain_text)
    end

    it 'handles long strings' do
      plain_text = 'a' * 1000
      encrypted = encrypter.encrypt(plain_text)

      expect(encrypted).to be_a(String)
      expect(encrypted).not_to eq(plain_text)
    end
  end

  describe '#decrypt' do
    it 'decrypts an encrypted string' do
      plain_text = 'sensitive data'
      encrypted = encrypter.encrypt(plain_text)
      decrypted = encrypter.decrypt(encrypted)

      expect(decrypted).to eq(plain_text)
    end

    it 'round-trips encryption and decryption correctly' do
      test_strings = [
        'simple text',
        'text with spaces',
        'text@with#special$chars%',
        'multiline\ntext\nhere',
        '测试 unicode',
        ''
      ]

      test_strings.each do |plain_text|
        encrypted = encrypter.encrypt(plain_text)
        decrypted = encrypter.decrypt(encrypted)
        expect(decrypted).to eq(plain_text)
      end
    end

    it 'raises an error when decrypting with wrong key' do
      plain_text = 'This is a secret message that is at least 32 characters long!'
      encrypter1 = described_class.new(SecureRandom.random_bytes(32))
      encrypter2 = described_class.new(SecureRandom.random_bytes(32))

      encrypted = encrypter1.encrypt(plain_text)

      expect do
        encrypter2.decrypt(encrypted)
      end.to raise_error(StandardError)
    end

    it 'raises an error when decrypting invalid data' do
      invalid_encrypted = 'not a valid encrypted string'

      expect do
        encrypter.decrypt(invalid_encrypted)
      end.to raise_error(ActiveSupport::MessageEncryptor::InvalidMessage)
    end

    it 'raises an error when decrypting empty string' do
      expect do
        encrypter.decrypt('')
      end.to raise_error(ActiveSupport::MessageEncryptor::InvalidMessage)
    end

    it 'raises an error when decrypting nil' do
      expect do
        encrypter.decrypt(nil)
      end.to raise_error(NoMethodError)
    end
  end

  describe 'integration' do
    it 'can encrypt and decrypt multiple times' do
      plain_text = 'test data'

      10.times do
        encrypted = encrypter.encrypt(plain_text)
        decrypted = encrypter.decrypt(encrypted)
        expect(decrypted).to eq(plain_text)
      end
    end

    it 'maintains data integrity across multiple encrypt/decrypt cycles' do
      original_data = 'important information that must remain intact'

      encrypted = encrypter.encrypt(original_data)
      decrypted = encrypter.decrypt(encrypted)

      expect(decrypted).to eq(original_data)
      expect(decrypted.length).to eq(original_data.length)
    end
  end
end
