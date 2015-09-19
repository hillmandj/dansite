class DraftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_json_response_format
  before_action :set_draft, except: [:index, :create]


  def index
    @drafts = Draft.unsaved.to_json
    render json: @drafts
  end

  def show
    render json: {title: @draft.title, content: @draft.content}, status: 200
  end

  def update
    if @draft.update(draft_params)
      render json: {status: 200, message: 'Draft updated'}, status: 200
    else
      render json: {status: 400, message: 'Draft failed to update'}, status: 400
    end
  end

  def create
    @draft = Draft.new(draft_params)
    if @draft.save
      render json: {status: 200, message: 'Draft saved'}, status: 200
    else
      render json: {status: 400, message: 'Draft failed to save'}, status: 400
    end
  end

  def destroy
    @draft.destroy
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
