class ApplicationController < ActionController::Base
  before_action :set_google_fonts
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  
  def set_google_fonts
    @fonts = ['Droid Serif', 'Dosis', 'Roboto', 'Open Sans', 'Rokkitt', 'Inconsolata', 'Raleway', 'Lato']
  end

  def after_sign_in_path_for(resource)
    posts_path
  end

  def after_sign_out_path_for(resource)
    posts_path
  end

  def admin?
    current_user.admin
  end
end
