class PagesController < InertiaController
  # Placeholder until site settings are editable in admin.
  SETTINGS = { show_heatmap: true, show_writing: true }.freeze

  def home
    render inertia: "home/index", props: {
      posts: Post.order(created_at: :desc).map { |post|
        { title: post.title, slug: post.slug, date: post.created_at.to_date.iso8601 }
      },
      contributions: SETTINGS[:show_heatmap] ? GithubContributions.current : nil,
      settings: SETTINGS
    }
  end
end
