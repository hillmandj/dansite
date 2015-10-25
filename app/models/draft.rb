class Draft < ActiveRecord::Base
  validates :title, :content, presence: true
end
