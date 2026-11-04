class ApplicationController < ActionController::Base
  private

  def after_sign_in_path_for(_resource)
    posts_path
  end

  def after_sign_out_path_for(_resource)
    posts_path
  end
end
