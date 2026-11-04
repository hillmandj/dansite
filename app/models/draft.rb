class Draft < ApplicationRecord
  validates :title, :content, presence: true
end
