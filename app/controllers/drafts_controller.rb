class DraftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draft, except: [:index, :create, :draft_count]
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
      @post = Post.create(title: @draft.title, content: @draft.content)
      @draft.destroy!
      redirect_to posts_path
    else
      render json: {status: 400, message: 'Draft failed to update'}, status: 400
    end
  end

  def create
    @draft = Draft.new(draft_params)
    if @draft.save
      redirect_to posts_path, notice: 'Draft saved'
    else
      render json: {status: 400, message: 'Draft failed to save'}, status: 400
    end
  end

  def destroy
    @draft.destroy
    redirect_to drafts_path, :notice => 'Draft deleted'
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
