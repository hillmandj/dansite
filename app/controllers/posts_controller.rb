class PostsController < InertiaController
  def index
    set_meta(title: "Writing", description: "Posts by Daniel Hillman.", path: posts_path)
    render inertia: "posts/index", props: {
      posts: Post.published.newest_first.map { |post| post_summary(post) }
    }
  end

  def show
    # Visitors only see published posts; the signed-in admin can preview drafts.
    @post = visible_posts.find_by!(slug: params[:id])
    set_meta(title: @post.title, description: @post.excerpt, path: post_path(@post), type: "article")

    render inertia: "posts/show", props: {
      post: post_summary(@post).merge(html: @post.html, reading_minutes: @post.reading_minutes, draft: !@post.published?),
      older: neighbor(:older),
      newer: neighbor(:newer)
    }
  end

  private

  def visible_posts
    user_signed_in? ? Post.all : Post.published
  end

  def post_summary(post)
    { title: post.title, slug: post.slug, date: post.date.iso8601 }
  end

  # The adjacent published post in publish order (nil at either end).
  def neighbor(direction)
    return unless @post.published?

    scope = Post.published.where.not(id: @post.id)
    post =
      if direction == :older
        scope.where(published_at: ...@post.published_at).order(published_at: :desc).first
      else
        scope.where(published_at: @post.published_at..).order(published_at: :asc).first
      end
    post && { title: post.title, slug: post.slug }
  end
end
