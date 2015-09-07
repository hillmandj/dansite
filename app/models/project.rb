class Project < ActiveRecord::Base
  validates :name, :position, :description, :site_url, :presence => true

  def has_image?
    self.image_url.present?
  end
end
