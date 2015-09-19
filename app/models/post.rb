class Post < ActiveRecord::Base
  has_one :draft
  validates :title, :content, :presence => true
end
