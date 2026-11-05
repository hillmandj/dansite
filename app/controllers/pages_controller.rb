class PagesController < InertiaController
  # Placeholder until site settings are editable in admin.
  SETTINGS = { show_heatmap: true, show_writing: true }.freeze

  def home
    set_meta(
      description: "Daniel Hillman is a Staff Software Engineer at Zendesk who builds web apps, " \
                   "developer tools and the infrastructure underneath them.",
      path: root_path
    )
    render inertia: "home/index", props: {
      posts: Post.published.newest_first.map { |post|
        { title: post.title, slug: post.slug, date: post.date.iso8601 }
      },
      contributions: SETTINGS[:show_heatmap] ? GithubContributions.current : nil,
      settings: SETTINGS
    }
  end
end
