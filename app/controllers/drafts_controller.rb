class DraftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draft, only: [ :show, :edit, :update, :destroy ]
  layout "blog"

  def index
    @drafts = Draft.order(created_at: :desc)
  end

  def show
    redirect_to edit_draft_path(@draft)
  end

  def preview
    render json: {
      preview_title: params[:title],
      preview_content: helpers.render_markdown(params[:content])
    }
  end

  def new
    @draft = Draft.new
  end

  def edit
  end

  def create
    @draft = Draft.new(draft_params)

    if params[:create_post]
      publish(@draft)
    elsif @draft.save
      redirect_to posts_path, notice: "Draft saved"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @draft.assign_attributes(draft_params)

    if params[:create_post]
      publish(@draft)
    elsif @draft.save
      redirect_to drafts_path, notice: "Draft updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @draft.destroy
    redirect_to drafts_path, notice: "Draft deleted", status: :see_other
  end

  def draft_count
    render json: { draft_count: Draft.count }
  end

  private

  # Turn a draft into a published post, removing the draft once the post saves.
  def publish(draft)
    @post = Post.new(title: draft.title, content: draft.content, published_at: Time.current)
    if @post.save
      draft.destroy if draft.persisted?
      redirect_to @post, notice: "Post created"
    else
      flash.now[:error] = @post.errors.full_messages.to_sentence
      render(draft.persisted? ? :edit : :new, status: :unprocessable_content)
    end
  end

  def set_draft
    @draft = Draft.find(params[:id])
  end

  def draft_params
    params.require(:draft).permit(:title, :content)
  end
end
