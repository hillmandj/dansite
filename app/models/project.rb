class Project < ActiveRecord::Base
  validates :name, :description, :image_url, :presence => true
end
