class Post < ApplicationRecord
  WORDS_PER_MINUTE = 220

  validates :title, :content, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  scope :published, -> { where.not(published_at: nil).where(published_at: ..Time.current) }
  scope :drafts, -> { where(published_at: nil) }
  scope :newest_first, -> { order(Arel.sql("COALESCE(published_at, created_at) DESC")) }

  def to_param
    slug
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  def html
    Markdown.render(content)
  end

  def excerpt(length = 160)
    Markdown.text(content).truncate(length, separator: " ")
  end

  def reading_minutes
    [ (Markdown.text(content).split.size / WORDS_PER_MINUTE.to_f).ceil, 1 ].max
  end

  # The publish date shown to readers (drafts fall back to when they were started).
  def date
    (published_at || created_at).to_date
  end

  private

  def generate_slug
    self.slug ||= title&.parameterize
  end
end
