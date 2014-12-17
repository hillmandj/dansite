class PostsController < ApplicationController
  layout 'blog'

  def index
    @posts = Post.order('created_at DESC')
  end

  def show
    @post = Post.find(params[:id])
  end
end
