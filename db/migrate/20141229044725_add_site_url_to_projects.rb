class AddSiteUrlToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :site_url, :string
  end

  def self.down
    remove_column :projects, :site_url
  end
end
