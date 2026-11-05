module PostsHelper
  # Used by the legacy admin views until the new admin replaces them.
  def render_markdown(source)
    Markdown.render(source)
  end
end
