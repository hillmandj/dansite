class Project < ActiveRecord::Base
  validates :name, :description, :site_url, :image_url, :presence => true
end
