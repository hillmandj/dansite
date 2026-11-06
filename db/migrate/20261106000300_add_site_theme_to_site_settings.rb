# The site-wide color theme, picked in the admin (see SiteSetting::THEMES).
class AddSiteThemeToSiteSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :site_settings, :site_theme, :string, default: "solarized", null: false
  end
end
