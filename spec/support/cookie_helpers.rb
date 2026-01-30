module CookieHelpers
  # Helper method to set signed cookies in request specs
  # Rack::Test::CookieJar doesn't support .signed, so we manually sign the cookie
  def set_signed_cookie(name, value)
    key_generator = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base, iterations: 1000)
    secret = key_generator.generate_key('signed cookie')
    verifier = ActiveSupport::MessageVerifier.new(secret)
    signed_value = verifier.generate(value)
    cookies[name] = signed_value
  end
end

RSpec.configure do |config|
  config.include CookieHelpers, type: :request
end
