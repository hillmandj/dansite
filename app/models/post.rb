class Post < ActiveRecord::Base
  has_many :drafts
  validates :title, :content, :presence => true
end
