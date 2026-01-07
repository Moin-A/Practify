module Practify
  class Encrypter
  def initialize(secret_key)
    @encryptor = ActiveSupport::MessageEncryptor.new(secret_key)
  end

  def encrypt(data)
    @encryptor.encrypt_and_sign(data)
  end


  def decrypt(encrypted_string)
    @encryptor.decrypt_and_verify(encrypted_string)
  end
  end
end
