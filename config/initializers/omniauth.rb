Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
    {
      scope: "email, profile, calendar",
      prompt: "consent",
      access_type: "offline",
      image_aspect_ratio: "square",
      image_size: 50
    }
end

# Resolve Rails 8 / OmniAuth CSRF protection issues
OmniAuth.config.allowed_request_methods = [ :post, :get ]
OmniAuth.config.silence_get_warning = true
