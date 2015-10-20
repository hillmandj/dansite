class DraftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draft, except: [:index, :create, :draft_count]
  layout 'blog'

  def index
    #@drafts = Draft.unsaved.to_json
    #render json: @drafts

    @drafts = Draft.unsaved
  end

  def show
  end

  def preview
    post_data = {
      preview_title: params['title'],
      preview_content: RedCloth.new(params['content']).to_html
    }
    render json: post_data
  end

  def edit
  end

  def update
    if @draft.update(draft_params)
      @post = @draft.create_post(title: @draft.title, content: @draft.content)
      redirect_to posts_path(@post)
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
    count = Draft.count
    render json: { draft_count: count }
  end

  private

  def set_draft
    @draft = Draft.find(params[:id])
  end

  def set_json_response_format
    request.format = :json
  end

  def draft_params
    params.require(:draft).permit(:title, :content)
  end
end
