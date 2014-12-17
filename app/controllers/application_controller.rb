class ApplicationController < ActionController::Base
  before_action :set_google_fonts
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  
  def set_google_fonts
    @fonts = ['Droid Serif', 'Ubuntu', 'Roboto', 'Open Sans', 'Rokkitt', 'Inconsolata', 'Oswald', 'Raleway', 'Signika Negative']
  end
end
