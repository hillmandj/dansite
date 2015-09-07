class PagesController < ApplicationController
  def about
  end

  def contact
  end

  def work
    @projects = Project.all.sort_by{|p| p.position}
  end
end
