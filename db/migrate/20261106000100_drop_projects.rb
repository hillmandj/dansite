# The old Work page listed projects from this table. The redesigned home page
# describes past work directly, so the table is unused. Its last contents are
# in the 2026-11-04 production backups.
class DropProjects < ActiveRecord::Migration[8.1]
  def up
    drop_table :projects
  end

  def down
    create_table :projects do |t|
      t.string :name, limit: 255
      t.text :description
      t.string :image_url, limit: 255
      t.string :site_url, limit: 255
      t.integer :position
      t.timestamps precision: nil
    end
  end
end
