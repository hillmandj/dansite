# Switches the admin can flip without a deploy (a single row).
class CreateSiteSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      t.boolean :show_heatmap, null: false, default: true
      t.boolean :show_writing, null: false, default: true
      t.timestamps
    end
  end
end
