require 'rails_helper'

RSpec.describe Project, :type => :model do

  let(:project) { build(:project) } 

  it 'should create a project' do
    project.save
    expect(Project.count).to eq(1)
  end

  it 'must have a name' do
    project.name = ''
    expect(project).not_to be_valid  
  end

  it 'must have an image' do
    project.image_url = nil
    expect(project).not_to be_valid
  end

  it 'must have a description' do
    project.description = ''
    expect(project).not_to be_valid
  end

  it 'can edit a project' do
    project.update(:name => 'New Name')
    project.save
    expect(project.name).to eq('New Name')
  end

  it 'should delete a project' do
    project.save
    project.delete
    expect(Project.count).to eq(0)
  end
end
