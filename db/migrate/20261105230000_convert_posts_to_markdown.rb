# Posts were written in Textile (RedCloth). From now on they are Markdown.
#
# - The original Textile is kept in posts.content_textile.
# - published_at marks a post as public; existing posts were all public, so it
#   is set to their creation time.
#
# The converter covers the Textile features the existing posts actually use.
class ConvertPostsToMarkdown < ActiveRecord::Migration[8.1]
  class Post < ActiveRecord::Base
    self.table_name = "posts"
  end

  module TextileToMarkdown
    module_function

    def convert(textile)
      blocks = []
      list = []
      flush_list = -> { blocks << list.join("\n") if list.any?; list = [] }

      lines(textile).each do |line|
        case line
        when %r{\A<br\s*/?>\z}i, ""
          flush_list.call
        when /\Ah4\.\s+\*(\d+)\.\s+(.+?)\*\s*(.*)\z/
          # "h4. *1. Habibi* (Craig Thompson)" -> numbered list item
          list << "#{$1}. **#{$2}**#{" #{inline($3)}" unless $3.empty?}"
        when /\Ap\{[^}]*\}\.\s+(.+)\z/
          # centered, underlined "p{...}. Title" -> section heading
          flush_list.call
          blocks << "## #{inline($1)}"
        when /\A!(\S+?)!\z/
          flush_list.call
          blocks << "![](#{$1})"
        when /\A<video/i
          flush_list.call
          blocks << line
        else
          flush_list.call
          blocks << inline(line)
        end
      end
      flush_list.call
      blocks.reject(&:empty?).join("\n\n") + "\n"
    end

    # One logical line per block; a <video>...</video> element becomes one line
    # with a single src and responsive-friendly attributes.
    def lines(textile)
      text = textile.gsub("\r\n", "\n").gsub(%r{<video\b.*?</video>}mi) do |video|
        src = video[/src="([^"]+)"/, 1]
        %(<video controls preload="metadata" src="#{src}"></video>)
      end
      text.split("\n").map(&:strip)
    end

    def inline(text)
      text
        .gsub(/"([^"]+?)":(\S+?)(?=[\s,;)]|[.!?](?:\s|\z)|\z)/) { "[#{$1}](#{$2})" }  # "text":url
        .gsub(/(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])/) { "**#{$1}**" }           # *bold*
        .gsub(/(?<![\w_])_(?!\s)(.+?)(?<!\s)_(?![\w_])/) { "*#{$1}*" }                # _italic_
        .gsub(" -- ", " — ")
    end
  end

  def up
    add_column :posts, :published_at, :datetime
    add_column :posts, :content_textile, :text
    add_index :posts, :published_at

    Post.reset_column_information
    Post.find_each do |post|
      post.update_columns(
        content_textile: post.content,
        content: TextileToMarkdown.convert(post.content.to_s),
        published_at: post.created_at
      )
    end
  end

  def down
    Post.find_each { |post| post.update_columns(content: post.content_textile) if post.content_textile }
    remove_index :posts, :published_at
    remove_column :posts, :content_textile
    remove_column :posts, :published_at
  end
end
