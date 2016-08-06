class DraftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draft, except: [:index, :preview, :new, :create, :draft_count]
  layout 'blog'

  def index
    @drafts = Draft.all.order('created_at DESC')
  end

  def show
  end

  def preview
    draft_data = {
      preview_title: params['title'],
      preview_content: RedCloth.new(params['content']).to_html
    }
    render json: draft_data
  end

  def edit
  end

  def update
    if @draft.update(draft_params)
      if params['update_draft']
        redirect_to drafts_path, notice: 'Draft Updated'
      elsif params['create_post']
        @post = Post.create(title: @draft.title, content: @draft.content)
        @draft.destroy!
        redirect_to posts_path
      end
    else
      flash[:error] = 'Draft failed to update'
    end
  end

  def new
    @draft = Draft.new
  end

  def create
    @draft = Draft.new(draft_params)

    if params['create_post']
      @post = Post.create(title: @draft.title, content: @draft.content)
      redirect_to @post, notice: 'Post created'
    elsif @draft.save!
      redirect_to posts_path, notice: 'Draft saved'
    else
      flash[:error] = 'Draft failed to save'
      render 'posts/new'
    end
  end

  def destroy
    @draft.destroy
    redirect_to drafts_path, notice: 'Draft deleted'
  end

  def draft_count
    count = Draft.all.count
    render json: { draft_count: count }
  end

  private

  def set_draft
    @draft = Draft.find(params[:id])
  end

  def draft_params
    params.require(:draft).permit(:title, :content)
  end
end
