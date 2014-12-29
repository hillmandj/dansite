class PagesController < ApplicationController
  def about
  end

  def contact
  end

  def work
    @projects = Project.all
  end
end
