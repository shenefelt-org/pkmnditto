class User < ApplicationRecord
  validates :sub, presence: true, uniqueness: true

  # Create or update a user from the OIDC ID-token claims returned by Replit Auth.
  def self.upsert_from_claims(claims)
    sub = claims[:sub] || claims["sub"]
    return nil if sub.blank?

    user = find_or_initialize_by(sub: sub.to_s)
    user.email             = claims[:email]             || claims["email"]
    user.first_name        = claims[:first_name]        || claims["first_name"] || claims[:given_name] || claims["given_name"]
    user.last_name         = claims[:last_name]         || claims["last_name"]  || claims[:family_name] || claims["family_name"]
    user.profile_image_url = claims[:profile_image_url] || claims["profile_image_url"] || claims[:picture] || claims["picture"]
    user.save!
    user
  end

  def display_name
    [first_name, last_name].compact.reject(&:blank?).join(" ").presence || email.presence || "Replit user"
  end
end
