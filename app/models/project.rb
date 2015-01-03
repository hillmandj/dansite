class Project < ActiveRecord::Base
  validates :name, :description, :site_url, :presence => true

  def has_image?
    self.image_url.present?
  end
end
