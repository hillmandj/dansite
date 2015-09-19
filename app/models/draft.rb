class Draft < ActiveRecord::Base
  belongs_to :post
  validates :title, :content, presence: true

  def self.unsaved
    where(post_id: nil)
  end
end
