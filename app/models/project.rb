class Project < ActiveRecord::Base
  validates :name, :description, :presence => true
  has_attached_file :photo, :styles => { :medium => '600x507>' }
end
