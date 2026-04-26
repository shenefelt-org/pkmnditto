class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :failure]

  # GET/POST /auth/replit/callback
  def create
    auth   = request.env["omniauth.auth"]
    claims = auth&.dig("info") || {}
    extra  = auth&.dig("extra", "raw_info") || {}

    merged_claims = {
      sub:               auth&.dig("uid") || extra["sub"],
      email:             claims["email"]  || extra["email"],
      first_name:        extra["first_name"] || claims["first_name"] || claims["name"],
      last_name:         extra["last_name"]  || claims["last_name"],
      profile_image_url: extra["profile_image_url"] || claims["image"]
    }

    user = User.upsert_from_claims(merged_claims)

    if user
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in as #{user.display_name}."
    else
      redirect_to root_path, alert: "Could not sign you in."
    end
  end

  # GET /signout
  def destroy
    reset_session
    end_session_url = "#{ISSUER_URL}/session/end?" + {
      client_id: ENV["REPL_ID"],
      post_logout_redirect_uri: request.base_url
    }.to_query
    redirect_to end_session_url, allow_other_host: true
  end

  # OmniAuth failure handler
  def failure
    redirect_to root_path, alert: "Sign-in failed: #{params[:message]}"
  end
end
