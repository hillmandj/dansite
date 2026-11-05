class PostsController < InertiaController
  # Public pages render with React; the admin actions keep the legacy Haml
  # views until the new admin replaces them.
  PUBLIC_ACTIONS = %w[index show].freeze
  layout -> { PUBLIC_ACTIONS.include?(action_name) ? "inertia" : "blog" }

  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_post, except: [ :index, :new, :preview, :create ]

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

  def new
    @post = Post.new
  end

  def preview
    render json: {
      preview_title: params[:title],
      preview_content: helpers.render_markdown(params[:content])
    }
  end

  def create
    @post = Post.new(post_params.merge(published_at: Time.current))
    if @post.save
      redirect_to @post, notice: "Post successfully created"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, notice: "Post successfully updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post deleted", status: :see_other
  end

  private

  def visible_posts
    user_signed_in? ? Post.all : Post.published
  end

  def set_post
    @post = Post.find_by!(slug: params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content)
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
