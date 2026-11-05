require_relative "20261105230000_convert_posts_to_markdown"

# Drafts used to live in their own table. Now a draft is a post without
# published_at. Draft content is converted from Textile to Markdown too.
class MoveDraftsIntoPosts < ActiveRecord::Migration[8.1]
  class Draft < ActiveRecord::Base
    self.table_name = "drafts"
  end

  class Post < ActiveRecord::Base
    self.table_name = "posts"
  end

  def up
    Draft.find_each do |draft|
      base = draft.title.to_s.parameterize.presence || "draft-#{draft.id}"
      slug = Post.exists?(slug: base) ? "#{base}-draft" : base
      Post.create!(
        title: draft.title,
        slug: slug,
        content: ConvertPostsToMarkdown::TextileToMarkdown.convert(draft.content.to_s),
        content_textile: draft.content,
        published_at: nil,
        created_at: draft.created_at,
        updated_at: draft.updated_at
      )
    end
    drop_table :drafts
  end

  def down
    create_table :drafts do |t|
      t.string :title, limit: 255
      t.text :content
      t.timestamps precision: nil
    end
    Post.where(published_at: nil).find_each do |post|
      Draft.create!(title: post.title, content: post.content_textile || post.content,
                    created_at: post.created_at, updated_at: post.updated_at)
      post.destroy!
    end
  end
end
