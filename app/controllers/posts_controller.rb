class PostsController < ApplicationController
  layout 'blog'
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :set_post, :except => [:index, :new, :create]

  def index
    @posts = Post.order('created_at DESC')
  end

  def show
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post, :notice => 'Post successfully created'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, :notice => 'Post successfully updated'
    else
      render 'edit'
    end 
  end

  def destroy
    @post.destroy
    redirect_to posts_path, :notice => 'Post deleted'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
