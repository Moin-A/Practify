module Practify
  class Encrypter
  def initialize(secret_key)
    key = ActiveSupport::KeyGenerator.new(secret_key).generate_key("practify_encrypter", 32)
    @encryptor = ActiveSupport::MessageEncryptor.new(key)
  end

  def encrypt(data)
    @encryptor.encrypt_and_sign(data)
  end


  def decrypt(encrypted_string)
    @encryptor.decrypt_and_verify(encrypted_string)
  end
  end
end
