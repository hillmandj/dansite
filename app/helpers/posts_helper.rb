module PostsHelper
  # Tags and attributes allowed in rendered posts, on top of Rails' safe defaults.
  # Existing posts embed <video> players and use inline styles.
  EXTRA_TAGS = %w[video source].freeze
  EXTRA_ATTRIBUTES = %w[style controls type].freeze

  # Render a post's Textile source to sanitized HTML.
  def render_textile(source)
    html = RedCloth.new(source.to_s).to_html
    sanitize(
      html,
      tags: Rails::HTML5::SafeListSanitizer.allowed_tags.to_a + EXTRA_TAGS,
      attributes: Rails::HTML5::SafeListSanitizer.allowed_attributes.to_a + EXTRA_ATTRIBUTES
    )
  end
end
