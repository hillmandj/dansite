class Post < ActiveRecord::Base
  validates :title, :content, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug ||= title.parameterize
  end
end
