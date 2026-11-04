class User < ApplicationRecord
  # Single admin account. Sign-up is disabled in routes; password reset is not enabled.
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable
end
