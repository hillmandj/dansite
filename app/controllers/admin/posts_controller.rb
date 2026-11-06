module Admin
  class PostsController < BaseController
    before_action :set_post, only: %i[edit update destroy]

    def index
      set_meta(title: "Posts", description: "Admin")
      render inertia: "admin/posts/index", props: {
        posts: Post.newest_first.map { |post| row(post) },
        settings: SiteSetting.current.as_props,
        themes: SiteSetting::THEMES.map { |key, theme| { key:, label: theme[:label] } }
      }
    end

    def new
      set_meta(title: "New post", description: "Admin")
      render inertia: "admin/posts/form", props: { post: form_props(Post.new(content: "")) }
    end

    def create
      @post = Post.new(post_attributes)
      if @post.save
        redirect_to edit_admin_post_path(@post), notice: "Post created."
      else
        redirect_to new_admin_post_path, inertia: { errors: @post.errors.to_hash(true).transform_values(&:to_sentence) }
      end
    end

    def edit
      set_meta(title: "Edit: #{@post.title}", description: "Admin")
      render inertia: "admin/posts/form", props: { post: form_props(@post) }
    end

    def update
      if @post.update(post_attributes)
        redirect_to edit_admin_post_path(@post), notice: "Saved."
      else
        redirect_to edit_admin_post_path(@post), inertia: { errors: @post.errors.to_hash(true).transform_values(&:to_sentence) }
      end
    end

    def destroy
      @post.destroy
      redirect_to admin_root_path, notice: "Deleted “#{@post.title}”."
    end

    # Live preview for the editor: Markdown in, sanitized HTML out.
    def preview
      render json: { html: Markdown.render(params[:content]) }
    end

    private

    def set_post
      @post = Post.find_by!(slug: params[:id])
    end

    # The editor sends `published` (a checkbox). Publishing keeps an existing
    # publish date; unpublishing turns the post back into a draft.
    def post_attributes
      attrs = params.require(:post).permit(:title, :content, :published)
      published = ActiveModel::Type::Boolean.new.cast(attrs.delete(:published))
      attrs[:published_at] = published ? (@post&.published_at || Time.current) : nil
      attrs
    end

    def row(post)
      { title: post.title, slug: post.slug, published: post.published?, updated: post.updated_at.to_date.iso8601 }
    end

    def form_props(post)
      { title: post.title.to_s, content: post.content.to_s, slug: post.slug,
        published: post.published?, persisted: post.persisted? }
    end
  end
end
