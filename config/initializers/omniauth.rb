require "omniauth"
require "omniauth_openid_connect"

# Replit Auth (OpenID Connect) - https://replit.com/oidc
# Replit acts as the OIDC provider; REPL_ID is the public client_id.
# Public client + PKCE means no client_secret is required.

ISSUER_URL = ENV.fetch("ISSUER_URL", "https://replit.com/oidc").freeze

# Build the redirect URI from the dev (or production) host so it matches
# what the Replit OIDC server expects.
def replit_auth_host
  domain = ENV["REPLIT_DEV_DOMAIN"].presence ||
           ENV["REPLIT_DOMAINS"].to_s.split(",").first.to_s.strip.presence
  domain.present? ? "https://#{domain}" : nil
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, {
    name: :replit,
    scope: [:openid, :profile, :email, :offline_access],
    response_type: :code,
    issuer: ISSUER_URL,
    discovery: true,
    pkce: true,
    client_options: {
      identifier:   ENV["REPL_ID"],
      secret:       nil,
      redirect_uri: "#{replit_auth_host}/auth/replit/callback"
    }
  }
end

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true

OmniAuth.config.on_failure = proc do |env|
  SessionsController.action(:failure).call(env)
end
