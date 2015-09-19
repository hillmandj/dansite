class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.string :title
      t.text :content
      t.references :post, index: true

      t.timestamps
    end
  end
end
