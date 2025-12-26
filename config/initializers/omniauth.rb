Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, 
    Rails.application.credentials.GOOGLE_CLIENT_ID, 
    Rails.application.credentials.GOOGLE_CLIENT_SECRET,
    {
      scope: 'email, profile, http://gdata.youtube.com',
      prompt: 'select_account',
      image_aspect_ratio: 'square',
      image_size: 50
    }
end
OmniAuth.config.allowed_request_methods = %i[get]