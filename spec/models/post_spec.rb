require 'rails_helper'

RSpec.describe Post, :type => :model do

  let(:post) { build(:post) }

  it 'should create a post' do
    post.save
    expect(Post.count).to eq(1)
  end

  it 'should not save without a title' do
    post.title = ''
    expect(post).not_to be_valid
  end

  it 'should not save without content' do
    post.content = ''
    expect(post).not_to be_valid
  end

  it 'should edit a post' do
    post.update(:title => 'New Title')
    post.save
    expect(post.title).to eq('New Title')
  end

  it 'should delete a post' do
    post.save
    post.delete
    expect(Post.count).to eq(0)
  end
end
