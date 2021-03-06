# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env == 'production'
  User.create(:email => ENV['ADMIN_EMAIL'], :password => ENV['ADMIN_PASSWORD'], :admin => true)
  Post.create(:title => 'Hello World!', :content => "Hi! Welcome to my blog. I'm happy to have finally finished the first version of this site. I still consider it a work in progress, but it was a great exercise. I encourage every developer to take the time to put one together.\nStay tuned for much more (actual) writing to come in the near future. Hope you guys drop by later and check it out!")
  Project.create([
                  {
                    :name => 'Handy',
                    :position => 0,
                    :description => "Handy is an on-demand home services platform that connects independent contractors with customers. After helping to build out the team's automated testing framework, I began doing full stack web development. I'm currently on the growth team, whose aim is to make it easier to onboard new providers and to increase the site's customer base.",
                    :image_url => 'projects/handy.png',
                    :site_url => 'http://www.handy.com'
                  },
                  {
                    :name => 'PublicStuff',
                    :position => 1,
                    :description => 'PublicStuff is a civic engagement tool that helps municipal governments solve problems in their communities. I worked there as a Consulting Developer for five months with a focus on front-end testing.',
                    :image_url => 'projects/publicstuff.png',
                    :site_url => 'http://www.publicstuff.com'
                  },
                  {
                    :name => 'Chloe + Isabel',
                    :position => 2,
                    :description => 'Chloe and Isabel is a jewelery brand that uses technology to facilitate the direct sale of it\'s products. I worked there initially as a QA Automation Engineer, writing code to ensure that the site functioned properly. I then began contributing to the site itself, fixing bugs and rebuilding portions of the site dedicated to it\'s administration',
                    :image_url => 'projects/cplusi.png',
                    :site_url => 'http://chloeandisabel.com'
                  },
                  {
                    :name => 'Tic Tac Toe',
                    :position => 3,
                    :description => 'A simple game of Tic Tac Toe using the recursive Minimax algorithm for AI. Try to beat it, if you can...',
                    :site_url => 'https://github.com/hillmandj/tictactoe'
                  },
                  {
                    :name => 'Huffman Encoder',
                    :position => 4,
                    :description => 'Python implementation of Huffman\'s compression algorithm.',
                    :site_url => 'https://github.com/hillmandj/huffmanencoder'
                  },
                  {
                    :name => 'Sort Bot',
                    :position => 5,
                    :description => 'This is a script I wrote while at MedTech Risk Management to help me sort the hundreds of incident reports they received each month automatically.',
                    :site_url => 'https://github.com/hillmandj/sort_bot'
                  }
                ])
end
