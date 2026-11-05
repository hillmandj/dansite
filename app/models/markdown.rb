# Renders post Markdown to sanitized HTML.
#
# Raw HTML is allowed in the source (posts embed <video> players), then
# everything goes through Rails' safe-list sanitizer, so scripts, event
# handlers and javascript: links are stripped.
module Markdown
  OPTIONS = {
    parse: { smart: true },
    render: { unsafe: true, hardbreaks: false },
    extension: { header_ids: nil, strikethrough: true, table: true, autolink: true }
  }.freeze

  TAGS = (Rails::HTML5::SafeListSanitizer.allowed_tags.to_a + %w[video source table thead tbody tr th td]).freeze
  ATTRIBUTES = (Rails::HTML5::SafeListSanitizer.allowed_attributes.to_a + %w[controls preload poster type]).freeze

  module_function

  def render(source)
    html = Commonmarker.to_html(source.to_s, options: OPTIONS)
    Rails::HTML5::SafeListSanitizer.new.sanitize(html, tags: TAGS, attributes: ATTRIBUTES)
  end

  # Plain text, for descriptions and reading time.
  def text(source)
    Nokogiri::HTML.fragment(render(source)).text.squish
  end
end
