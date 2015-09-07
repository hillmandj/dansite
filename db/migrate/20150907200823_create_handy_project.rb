class CreateHandyProject < ActiveRecord::Migration
  def up
    handy_project = Project.create(
      name: 'Handy',
      description: 'Handy is an on-demand home services platform that connects independent contractors with customers. After helping to build out the team\'s automated testing framework, I began doing full stack web development. I\'m currently on the growth team, whose aim is to make it easier to onboard new providers and to increase the site\'s customer base.',
      image_url: 'projects/handy.png',
      site_url: 'http://www.handy.com'
    )
  end

  def down
    handy_project = Project.find_by_name('Handy')
    handy_project.destroy if handy_project
  end
end
