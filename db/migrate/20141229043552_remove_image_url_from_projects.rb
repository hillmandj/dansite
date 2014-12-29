class RemoveImageUrlFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :image_url
  end

  def self.down
    add_column :projects, :image_url, :string
  end
end
